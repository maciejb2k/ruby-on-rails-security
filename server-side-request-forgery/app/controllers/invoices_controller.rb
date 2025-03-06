require 'open-uri'

class InvoicesController < ApplicationController
  before_action :set_invoice, only: %i[show edit update destroy]

  # GET /invoices
  def index
    @invoices = Invoice.order(created_at: :desc)
  end

  # GET /invoices/1
  def show
  end

  # GET /invoices/new
  def new
    @invoice = Invoice.new
  end

  # GET /invoices/1/edit
  def edit
  end

  # POST /invoices
  def create
    @invoice = Invoice.new(invoice_params)
    @invoice.status = :pending

    begin
      file = URI.open(@invoice.url)
      file_content = file.read

      @invoice.raw_data = file_content

      extracted_text = extract_text(file_content)

      @invoice.parsed_data = extracted_text
      @invoice.status = 'processed'
    rescue StandardError => e
      @invoice.status = 'failed'
      @invoice.raw_data = "There was an error during parsing: #{e.message}"
    end

    if @invoice.save
      redirect_to @invoice, notice: 'Invoice was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /invoices/1
  def update
    if @invoice.update(invoice_params)
      redirect_to @invoice, notice: 'Invoice was successfully updated.', status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /invoices/1
  def destroy
    @invoice.destroy!
    redirect_to invoices_url, notice: 'Invoice was successfully destroyed.', status: :see_other
  end

  private

  def extract_text(file_content)
    "Przetworzona zawartość faktury PDF dla #{@invoice.name}"
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_invoice
    @invoice = Invoice.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def invoice_params
    params.require(:invoice).permit(:url, :raw_data, :status, :name, :issue_date)
  end
end
