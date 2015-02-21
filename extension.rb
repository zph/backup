module TimeConverter
  DOTTED_TIME_FORMAT = %w[%Y m d H M S].join('.%')

  def to_datetime
    DateTime.strptime(mod.time, DOTTED_TIME_FORMAT)
  end

  def to_time
    DateTime.strptime(mod.time, DOTTED_TIME_FORMAT).to_time
  end

  def to_epoch
    to_time.to_i
  end
end

class Fixnum
  SEC_PER_MIN = 60
  MIN_PER_HOUR = 60
  HOUR_PER_DAY = 24
  DAYS_PER_YEAR = 365

  TIME_CONVERSIONS = [
    SEC_PER_MIN,
    MIN_PER_HOUR,
    HOUR_PER_DAY,
  ]

  def sec_to_min
    self / SEC_PER_MIN
  end

  def min_to_hour
    self / MIN_PER_HOUR
  end

  def hour_to_min
    self * MIN_PER_HOUR
  end

  def min_to_sec
    self * TIME_CONVERSIONS.first
  end

  def hour_to_sec
    self * TIME_CONVERSIONS.take(2).inject(:*)
  end
end

class Backup::Model
  def plain_model(model = self)
    storage_model = model.dup

    procs = storage_model.instance_variables.select do |m|
      storage_model.instance_variable_get(m).kind_of? Proc
    end

    # unset procs, doesn't work for procs nested below one level
    procs.each { |p| storage_model.instance_variable_set(p, nil) }

    storage_model
  end
end
