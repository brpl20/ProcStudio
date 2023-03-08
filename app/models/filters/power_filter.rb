class PowerFilter
  class << self
    def by_cat(category)
      Power.where(category: category).order(:category)
    end
  end
end