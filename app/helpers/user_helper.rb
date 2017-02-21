##

# helpers used for EmailTemplate views
module UserHelper
  def build_schedule_for_user
    # sanity check
    return if @user.nil?

    @user.schedule ||= @user.build_schedule

    # we need this
    @user.schedule
  end

  def localize_day_name(weekday)
    t('date.day_names')[weekday].downcase
  end

end
