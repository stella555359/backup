edaemon_ip = '127.0.0.1'
edaemon_port = '10000'
s1_ip = "10.0.1.1"

pgw_net_part = '1.7'
pgw_ip = '1.7.255.254/16'

s1u_port = "2152"
s11_port = "2153"

mme_port = "36412"
mmegi = "1"
mmec = "3"

uec_ip = "11.7.255.254/16"
uec_net_part = "11.7"
uec_server_ip = "10.0.2.1"
uec_proxy_ip = "10.0.2.2"
uec_proxy_port = "2152"

plmn = "244:09"
enb_s1_ip = "10.0.1.2"
enb_macro_id = "0x00001"

tac = "124"

sec_key='0102030405060708090A0B0C0D0E'
sec_op_key = 'ABCDEF0123456789ABCDEF0123456789'
imsi_prefix = '666:652:40500'

ue_count_per_cell = 10
cells = { 1 }

exec("set_pgw"..
     " id=1"..
     " type=simulated"..
     " ip="..edaemon_ip..":"..edaemon_port..
     " devtype=tun "..
     " devname=tunPGW"..
     " addr="..pgw_ip)

exec("set_sgw"..
     " id=1"..
     " type=simulated"..
     " ip="..edaemon_ip..":"..edaemon_port..
     " s1u="..s1_ip..":"..s1u_port..
     " s11="..s1_ip..":"..s11_port)

exec("set_mme"..
     " id=1"..
     " type=simulated"..
     " ip="..edaemon_ip..":"..edaemon_port..
     " s1="..s1_ip..":"..mme_port..
     " mmegi="..mmegi..
     " mmec="..mmec)

exec("set_uec"..
     " id=1"..
     " ip="..edaemon_ip..":"..edaemon_port..
     " gtpu=on"..
     " pdn=1"..
     " addr="..uec_ip..
     " peer="..uec_server_ip..":"..uec_proxy_port..
     " retries=unlimited")

exec("set_enb type=external"..
     " id=1"..
     " plmn="..plmn..
     " enb_id_macro="..enb_macro_id..
     " s1="..enb_s1_ip..
     " daemon="..edaemon_ip..":"..edaemon_port)

for cell_id, phy_cell_id in pairs(cells) do
    idx = cell_id +10
    exec("set_cell"..
         " id="..idx..
         " enb=1"..
         " pci="..math.floor(phy_cell_id/3)..":"..math.fmod(phy_cell_id,3)..
         " tac="..tac..
         " proxy="..uec_proxy_ip..":"..uec_proxy_port..
         " eci="..enb_macro_id.."0"..string.format("%X", idx))
end

local cell_count = table.getn(cells)

for cell_id=1,cell_count do
    for ue_index=1,ue_count_per_cell do

        local ue_id = (cell_id - 1) * ue_count_per_cell + ue_index

        local ue_id_aligned
        if (ue_index>0 and ue_index<10) then ue_id_aligned = '00'..ue_index
        elseif (ue_index>=10 and ue_index<100) then ue_id_aligned = '0'..ue_index
        elseif (ue_index>=100 and ue_index<1000) then ue_id_aligned = ue_index
        end

        local rohc_profile = '16'
        local ue_sec_key = sec_key..cell_id..ue_id_aligned
        local ue_imsi = imsi_prefix..cell_id..ue_id_aligned
        local ue_ip = pgw_net_part..'.'..cell_id..'.'..ue_index

        exec('set_ue id='..ue_id..
             ' rohc='..rohc_profile..
             ' sec_key='..ue_sec_key..
             ' imsi='..ue_imsi..
             ' cell='..cell_id+10)

        exec('set_bearer id=1'..
             ' ue='..ue_id..
             ' trf_type=internal'..
             ' default=on'..
             ' qci=8'..
             ' ip='..ue_ip)
    end
end

exec('set_log log_to_file=on')
exec("cfg_end")

sleep(1)
