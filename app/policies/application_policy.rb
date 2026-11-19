
class ApplicationPolicy
  include RoleHelpers
  attr_reader :user, :record

  def initialize(user, record)
    @user = user # Logged-in user	Admin, Manager, Learner
    @record = record # Resource being authorized	Course, Lesson, Category
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def update?
    false
  end

  def destroy?
    false
  end
  # ABOVE IS A : security-first approach.
  # If you forget to define destroy? in a particular policy,
  # # the inherited method denies access instead of accidentally allowing it.

  # A nested Ruby class is not automatically a subclass of its enclosing class.
  class Scope  # scope is the collection being filtered.
    include RoleHelpers  # nested class Scope is not automatically a subclass of its enclosing class.
    # It needs its own helper methods or a shared module.
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve # resolve returns the authorized records.
      raise NotImplementedError
    end
  end

  protected

  def admin?
    user&.role&.name == "admin"
  end

  def manager?
    user&.role&.name == "manager"
  end

  def learner?
    user&.role&.name == "learner"
  end
end
