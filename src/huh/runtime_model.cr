module Huh
  # RuntimeModel adapts Huh models that render String views into Tea::Model views.
  class RuntimeModel(T)
    include Tea::Model

    getter model : T

    @model : T

    def initialize(@model : T)
    end

    def init : Tea::Cmd?
      @model.init
    end

    def update(msg : ::Tea::Msg)
      updated, cmd = @model.update(msg)
      @model = updated
      {self, cmd}
    end

    def view : Tea::View
      Tea::View.new(@model.view)
    end
  end
end
