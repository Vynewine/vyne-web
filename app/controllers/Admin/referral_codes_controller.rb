class Admin::ReferralCodesController < ApplicationController
  layout 'admin'
  before_action :authenticate_user!
  authorize_actions_for AdminAuthorizer

  def create
    @referral_code = ReferralCode.new({
                                      referral_id: params[:referral_id],
                                      code: params[:code].upcase
                                  })
    if @referral_code.save
      redirect_to [:admin, @referral_code.referral], notice: 'Referral Code was successfully created.'
    else
      flash[:error] = @referral_code.errors.full_messages.join(', ')
      redirect_to [:admin, @referral_code.referral]
    end
  end

  def update
    @referral_code = ReferralCode.find(params[:id])
    if @referral_code.update({
                                 referral_id: params[:referral_id],
                                 code: params[:code]
                             })
      redirect_to [:admin, @referral_code.referral], notice: 'Referral Code was successfully updated.'
    else
      flash[:error] = @referral_code.errors.full_messages.join(', ')
      redirect_to [:admin, @referral_code.referral]
    end
  end

  def destroy
    @referral_code = ReferralCode.find(params[:id])
    @referral_code.destroy
    redirect_to [:admin, @referral_code.referral], notice: 'Referral Code was successfully removed.'
  end
end