class RulesController < ApplicationController

  load_and_authorize_resource :rule

  before_action :load_resources

  def index
    @rules = @rules.paginate(page: params[:page])
  end

  def new
  end

  def create
    @rule = Rule.new(rule_params)

    if @rule.save
      redirect_to rules_url, notice: t(:rule_added)
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @rule.update_attributes(rule_params)
      redirect_to rules_url, notice: t(:rule_modified)
    else
      render 'edit'
    end
  end

  def destroy
    @rule.destroy

    redirect_to rules_url, notice: t(:rule_deleted)
  end

  protected
    def rule_params
      params.require(:rule).permit(
          :filter_field,
          :filter_operation,
          :filter_value,
          :action_operation,
          :action_value,
      )
    end

    def load_resources
      @label_options = Label.ordered.map do |l|
        {
          key: l.name,
          value: l.name,
        }
      end
      @users = User.agents.ordered.map do |u|
        {
          key: u.email,
          value: u.email
        }
      end
      @statuses = Ticket.statuses.except(:merged).map do |s,i|
        {
          key: s,
          value: t(s, scope: 'activerecord.attributes.ticket.statuses')
        }
      end
      @priorities = Ticket.priorities.map do |p,i|
        {
          key: p,
          value: t(p)
        }
      end
    end

end
