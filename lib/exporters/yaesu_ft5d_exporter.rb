class YaesuFt5dExporter < Exporter
  def export
    headers = [
      "Channel No", "Priority CH", "Receive Frequency", "Transmit Frequency", "Offset Frequency", "Offset Direction",
      "AUTO MODE", "Operating Mode", "DIG/ANALOG", "TAG", "Name", "Tone Mode", "CTCSS Frequency", "DCS Code",
      "DCS Polarity", "User CTCSS", "RX DG-ID", "TX DG-ID", "Tx Power", "Skip", "AUTO STEP", "Step", "Memory Mask",
      "ATT", "S-Meter SQL", "Bell", "Narrow", "Clock Shift", "BANK1", "BANK2", "BANK3", "BANK4", "BANK5", "BANK6",
      "BANK7", "BANK8", "BANK9", "BANK10", "BANK11", "BANK12", "BANK13", "BANK14", "BANK15", "BANK16", "BANK17",
      "BANK18", "BANK19", "BANK20", "BANK21", "BANK22", "BANK23", "BANK24", "Comment"
    ]

    puts headers
  end
end
