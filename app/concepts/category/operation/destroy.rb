module Category::Operation
  class Destroy < Trailblazer::Operation
    step :find_category
    step :delete_category
    fail :handle_failure

    def find_category(ctx, params:, **)
      ctx[:model] = Category.find_by(id: params[:id])
      return false unless ctx[:model]

      true
    end

    def delete_category(ctx, **)
      if ctx[:model].destroy
        true
      else
        ctx[:errors] = ctx[:model].errors.full_messages
        false
      end
    end

    def handle_failure(ctx, **)
      ctx[:error] ||= "Category deletion failed"
    end
  end
end
