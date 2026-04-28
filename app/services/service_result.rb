# frozen_string_literal: true

ServiceResult = Struct.new(:success, :data, :error, :details, keyword_init: true) do
  def success?
    success
  end

  def failure?
    !success
  end
end
