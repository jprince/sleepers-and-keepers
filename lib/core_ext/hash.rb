Hash.class_eval do
  def camelize
    Hash[map { |k, v| [k.to_s.camelcase(:lower), v.respond_to?(:keys) ? v.camelize : v] }]
  end
end
