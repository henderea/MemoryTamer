class Bind
  def initialize(id, control, key_path, &listener)
    @id = id
    @control = control
    @key_path = key_path
    @listener = listener
  end
end