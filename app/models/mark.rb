class Mark < ActiveRecord::Base
  # When a mark is created, or updated, we need to make sure that that
  # Result has not been released to students
  before_save :ensure_not_released_to_students
  before_update :ensure_not_released_to_students

  belongs_to :markable, :polymorphic => true
  belongs_to :result
  validates_presence_of :result_id, :markable_id, :markable_type
  validates_numericality_of :result_id, :only_integer => true, :greater_than => 0, :message => "result_id must be an id that is an integer greater than 0"
  validates_numericality_of :mark, :allow_nil => true, :message => "must be a number"
  validates_numericality_of :markable_id, :only_integer => true, :greater_than => 0, :message => "Criterion must be an id that is an integer greater than 0"
  validates_uniqueness_of :markable_id, :scope => [:result_id, :markable_type]

  def validate
    if self.markable_type == "RubricCriterion" and !self.mark.nil? and (self.mark > 4 or self.mark < 0)
      errors.add(:mark, I18n.t("mark.error.validate_rubric"))
    end
    if self.markable_type == "FlexibleCriterion" and !self.mark.nil? and (self.mark > self.markable.max or self.mark < 0)
      errors.add(:mark, I18n.t("mark.error.validate_flexible"))
    end
  end
  #return the current mark for this criterion
  def get_mark
    criterion = self.markable
    weight = criterion.get_weight
    return mark.to_f * weight
  end
  
  private
  
  def ensure_not_released_to_students
    return !result.released_to_students
  end
end

