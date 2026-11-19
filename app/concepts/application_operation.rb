# Shared request-level Pundit access for API operations.
class ApplicationOperation < Trailblazer::Operation
  private

  def pundit_context(ctx)
    Pundit::Context.new(user: ctx[:current_user])
  end

  def authorize_record(ctx, record, query, policy_class: nil)
    pundit_context(ctx).authorize(record, query: query, policy_class: policy_class)
  end

  def policy_scope_for(ctx, model)
    pundit_context(ctx).policy_scope(model)
  end
end
