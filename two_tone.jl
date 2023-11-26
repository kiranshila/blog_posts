using CSV, Plots

db2lin(db) = 10^(db / 10)
lin2db(lin) = 10 * log10(lin)

# Low Level Noise (Noise floor of RX) -> Nl (dBm/Hz)
nl_file = CSV.File("/run/media/kiran/A852-7701/distortion/nl.csv", skipto=9, header=[:freq, :dbm, :phase], limit=401)
bandwidth = 100  # Hz
nl = nl_file[:dbm] .- 10 * log(bandwidth) # dBm / Hz

# High Level Noise (Phase noise of close tone) -> Nh (dBc/Hz) zero

# Receiver intermod
im3_file = CSV.File("/run/media/kiran/A852-7701/distortion/im3.csv", skipto=9, header=[:freq, :dbm, :phase], limit=401)
ip3 = @. (3 * -10 - im3_file[:dbm]) / 2

evm = @. 20 * log10(10^(im3_file[:dbm] / 20) + 10^((nl + 6) / 20)) + 10