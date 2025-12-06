class System < ApplicationRecord
  # Constants
  MODES = [ "analog", "dmr", "p25", "nxdn" ].freeze
  BANDWIDTHS = [ "12.5 kHz", "20 kHz", "25 kHz" ].freeze

  # CTCSS Tones in Hz (stored as strings to preserve decimal precision)
  CTCSS_TONES = [
    "67.0", "71.9", "74.4", "77.0", "79.7", "82.5", "85.4", "88.5", "91.5", "94.8",
    "97.4", "100.0", "103.5", "107.2", "110.9", "114.8", "118.8", "123.0", "127.3", "131.8",
    "136.5", "141.3", "146.2", "151.4", "156.7", "162.2", "167.9", "173.8", "179.9", "186.2",
    "192.8", "203.5", "210.7", "218.1", "225.7", "233.6", "241.8", "250.3"
  ].freeze

  # DCS Codes (3-digit codes with leading zeros)
  DCS_CODES = [
    "023", "025", "026", "031", "032", "036", "043", "047", "051", "053", "054", "065", "071", "072", "073", "074",
    "114", "115", "116", "122", "125", "131", "132", "134", "143", "145", "152", "155", "156", "162", "165", "172",
    "174", "205", "212", "223", "225", "226", "243", "244", "245", "246", "251", "252", "255", "261", "263", "265",
    "266", "271", "274", "306", "311", "315", "325", "331", "332", "343", "346", "351", "356", "364", "365", "371",
    "411", "412", "413", "423", "431", "432", "445", "446", "452", "454", "455", "462", "464", "465", "466", "503",
    "506", "516", "523", "526", "532", "546", "565", "606", "612", "624", "627", "631", "632", "654", "662", "664",
    "703", "712", "723", "731", "732", "734", "743", "754"
  ].freeze

  # Combined list for grouped dropdown (user-friendly labels)
  TONE_OPTIONS = [
    [ "CTCSS Tones", CTCSS_TONES.map { |t| [ "#{t} Hz", t ] } ],
    [ "DCS Codes", DCS_CODES.map { |d| [ "D#{d}N", d ] } ]
  ].freeze

  # Associations
  belongs_to :mode_detail, polymorphic: true, optional: true

  has_many :system_networks, dependent: :destroy
  has_many :networks, through: :system_networks

  has_many :system_talk_groups, dependent: :destroy
  has_many :talk_groups, through: :system_talk_groups

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
