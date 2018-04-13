class Version
  class << self
    def current
      @version ||= Version.new(NSBundle.mainBundle.infoDictionary['CFBundleShortVersionString'])
    end

    def last
      @last_version ||= Version.new(self.version.to_s)
    end

    def last=(last_version)
      @last_version = Version.new(last_version || self.version.to_s)
    end
  end

  def initialize(version)
    @version = version || '0.0'
  end

  def <=>(other)
    other = Version.new(other && other.to_s)
    p     = parts
    op    = other.parts
    p <=> op
  end

  def <(other)
    (self <=> other) < 0
  end

  def <=(other)
    (self <=> other) <= 0
  end

  def ==(other)
    (self <=> other) == 0
  end

  def >(other)
    (self <=> other) > 0
  end

  def >=(other)
    (self <=> other) >= 0
  end

  def parts
    @version.gsub(/^(\d+)([^.]*)$/, '\1.0.0\2').gsub(/^(\d+)\.(\d+)([^.]*)$/, '\1.\2.0\3').gsub(/\.(\d+)$/, '\.\1.0').gsub(/\.(\d+)b(\d+)$/, '.\1.-1.\2').split(/\./).map(&:to_i)
  end

  def to_s
    @version
  end

  def inspect
    self.to_s
  end
end