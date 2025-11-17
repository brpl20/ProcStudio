class StorageMetricsJob < ApplicationJob
  queue_as :low

  def perform(team_id = nil)
    Rails.logger.info "Calculating storage metrics#{team_id ? " for team #{team_id}" : ''}..."

    if team_id
      calculate_team_metrics(team_id)
    else
      # Calculate metrics for all teams
      Team.find_each do |team|
        calculate_team_metrics(team.id)
      end
    end
  end

  private

  def calculate_team_metrics(team_id)
    # Get all files for a team
    files = S3Manager.list(team_id)

    metrics = {
      team_id: team_id,
      total_files: files.count,
      total_size: files.sum(&:byte_size),
      system_files: files.system_generated.count,
      user_files: files.user_uploaded.count,
      temporary_files: files.temporary.count,
      expired_files: files.expired.count,
      by_category: calculate_category_breakdown(files),
      by_month: calculate_monthly_breakdown(files)
    }

    # Store metrics (could be in Redis, database, or monitoring system)
    store_metrics(team_id, metrics)

    Rails.logger.info "Storage metrics calculated for team #{team_id}: #{metrics[:total_files]} files, #{format_bytes(metrics[:total_size])}"

    metrics
  end

  def calculate_category_breakdown(files)
    FileMetadata::FILE_CATEGORIES.each_with_object({}) do |category, hash|
      category_files = files.by_category(category)
      hash[category] = {
        count: category_files.count,
        size: category_files.sum(&:byte_size)
      }
    end
  end

  def calculate_monthly_breakdown(files)
    # Group by month for the last 6 months
    6.times.map do |i|
      date = i.months.ago.beginning_of_month
      month_files = files.where(uploaded_at: date..date.end_of_month)

      {
        month: date.strftime('%Y-%m'),
        count: month_files.count,
        size: month_files.sum(&:byte_size)
      }
    end.reverse
  end

  def store_metrics(team_id, metrics)
    # Store in Redis for quick access (if Redis is configured)
    if defined?(Redis) && Redis.current
      Redis.current.setex(
        "storage_metrics:team:#{team_id}",
        1.hour.to_i,
        metrics.to_json
      )
    end

    # Could also store in database or send to monitoring service
    # Example: TeamStorageMetric.create!(team_id: team_id, metrics: metrics)
  end

  def format_bytes(bytes)
    return '0 B' if bytes.zero?

    units = %w[B KB MB GB TB]
    index = (Math.log(bytes) / Math.log(1024)).floor
    size = bytes / (1024.0 ** index)

    "#{size.round(2)} #{units[index]}"
  end
end