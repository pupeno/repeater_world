class IcomId51Exporter < IcomId51AndId52Exporter
  def dstar_repeater(repeater)
    row = super(repeater)

    row["TONE"] = "OFF" # It's D-Star, of course it's off. But ID-51 seems to want it this way.
    row["Repeater Tone"] = "88.5Hz" # ID-51 insists it wants this to be 88.5Hz. The ID-52 has a similar broken behaviour.
    row
  end
end
