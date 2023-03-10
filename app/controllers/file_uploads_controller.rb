class FileUploadsController < BackofficeController
  def new
    @profile_customer = ProfileCustomer.find(params[:profile_customer_id])
  end

  def destroy
    @profile_customer = Client.find(params[:profile_customer_id])
    @profile_customer.files.find(params[:id]).purge
    redirect_to request.referrer
  end

  def destroy_file_work
    @work = Work.find(params[:work_id])
    @work.archive_file.find(params[:id]).purge
    redirect_to request.referrer
  end
end
