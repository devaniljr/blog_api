# frozen_string_literal: true

class ApplicationService
  def self.call(...)
    new(...).call
  end

  private

  def success(data = nil)
    ServiceResult.new(success: true, data: data)
  end

  def failure(error, details: nil)
    ServiceResult.new(success: false, error: error, details: details)
  end
end
