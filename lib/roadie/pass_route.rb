class PassRoute
  NOT_FOUND = [404, { 'Content-Type' => 'text/plain', 'X-Cascade' => 'pass' }, ['Not Found']]

  def call(_)
    NOT_FOUND
  end

  def expand_url(_, _)
    nil
  end
end
