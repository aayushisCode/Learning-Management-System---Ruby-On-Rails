module RoleHelpers
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
