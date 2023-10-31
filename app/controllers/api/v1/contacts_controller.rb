class Api::V1::ContactsController < Api::V1::InternalController

  def create
    @contact = Contact.new(contact_params)

    if @contact.save
      render json: @contact, status: :created
    else
      render json: { errors: @contact.errors.full_messages }, status: :unprocessable_entity
    end
  end
  def upsert
    @contact = get_by_params(@current_user, contact_params)
    if @contact
      @contact.update!(contact_params)
      render json: @contact, status: :ok
    else
      Contact.create!(contact_params)
      render json: @contact, status: :created
    end 
  end
  def contact_params
    params.permit(:full_name, :phone, :email)
  end
end
