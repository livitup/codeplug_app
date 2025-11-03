class System < ApplicationRecord
  # Constants
  MODES = [ "analog", "dmr", "p25", "nxdn" ].freeze

  # Associations
  belongs_to :mode_detail, polymorphic: true, optional: true

  has_many :system_networks, dependent: :destroy
  has_many :networks, through: :system_networks

  # TODO: Uncomment when SystemTalkGroup join model is implemented
  # has_many :system_talk_groups, dependent: :destroy
  # has_many :talk_groups, through: :system_talk_groups

  # TODO: Uncomment when Channel model is implemented
  # has_many :channels

  # Virtual attributes for mode detail fields
  attr_accessor :color_code, :nac

  # Callbacks
  before_validation :build_or_update_mode_detail
  after_find :populate_mode_detail_attributes

  # Validations
  validates :name, presence: true
  validates :mode, presence: true, inclusion: { in: MODES, message: "%{value} is not a valid mode" }
  validates :tx_frequency, presence: true
  validates :rx_frequency, presence: true

  # Mode detail validations
  validates :color_code, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 15 }, if: -> { mode == "dmr" }, allow_blank: false
  validates :nac, presence: true, if: -> { mode == "p25" }

  private

  def build_or_update_mode_detail
    return unless mode.present?

    case mode
    when "dmr"
      build_dmr_mode_detail
    when "p25"
      build_p25_mode_detail
    when "analog", "nxdn"
      build_analog_mode_detail
    end
  end

  def build_dmr_mode_detail
    if mode_detail && mode_detail.is_a?(DmrModeDetail)
      mode_detail.color_code = color_code
    else
      self.mode_detail = DmrModeDetail.new(color_code: color_code)
    end
  end

  def build_p25_mode_detail
    if mode_detail && mode_detail.is_a?(P25ModeDetail)
      mode_detail.nac = nac
    else
      self.mode_detail = P25ModeDetail.new(nac: nac)
    end
  end

  def build_analog_mode_detail
    if mode_detail && mode_detail.is_a?(AnalogModeDetail)
      # No additional fields for analog
    else
      self.mode_detail = AnalogModeDetail.new
    end
  end

  def populate_mode_detail_attributes
    return unless mode_detail

    case mode_detail
    when DmrModeDetail
      self.color_code = mode_detail.color_code
    when P25ModeDetail
      self.nac = mode_detail.nac
    end
  end
end
