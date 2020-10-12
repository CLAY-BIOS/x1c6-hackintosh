#! /bin/zsh
# ThunderboltUtil.sh v1.5
# by joevt Jul 7, 2020
# Source: https://gist.github.com/joevt/4f6d4d97b560efab9603ac509bf00122

#=========================================================================================
#           
#           
#           Thunderbolt DROM Notes:
#           
#           
#           https://lore.kernel.org/patchwork/patch/714766/
#           
#           Macs with Thunderbolt 1 do not have a unit-specific DROM: The DROM is
#           empty with uid 0x1000000000000. (Apple started factory-burning a unit-
#           specific DROM with Thunderbolt 2.)
#           
#           Instead, the NHI EFI driver supplies a DROM in a device property. Use
#           it if available. It's only available when booting with the efistub.
#           If it's not available, silently fall back to our hardcoded DROM.
#           
#           The size of the DROM is always 256 bytes. The number is hardcoded into
#           the NHI EFI driver. This commit can deal with an arbitrary size however,
#           just in case they ever change that.
#           
#           A modification is needed in the resume code where we currently read the
#           uid of all switches in the hierarchy to detect plug events that occurred
#           during sleep. On Thunderbolt 1 root switches this will now lead to a
#           mismatch between the uid of the empty DROM and the EFI DROM. Exempt the
#           root switch from this check: It's built in, so the uid should never
#           change. However we continue to *read* the uid of the root switch, this
#           seems like a good way to test its reachability after resume.
#           
#           Background information: The EFI firmware volume contains ROM files for
#           the NHI, GMUX and several other chips as well as key material. This
#           strategy allows Apple to deploy ROM or key updates by simply publishing
#           an EFI firmware update on their website. Drivers do not access those
#           files directly but rather through a file server via EFI protocol
#           AC5E4829-A8FD-440B-AF33-9FFE013B12D8. Files are identified by GUID, the
#           NHI DROM has 339370BD-CFC6-4454-8EF7-704653120818.
#           
#           The NHI EFI driver amends that file with a unit-specific uid. The uid
#           has 64 bit but its entropy is much lower: 24 bit represent the model,
#           24 bit are taken from a serial number, 16 bit are fixed. The NHI EFI
#           driver obtains the serial number via the DataHub protocol, copies it
#           into the DROM, calculates the CRC and submits the result as a device
#           property.
#           
#           
#           https://github.com/torvalds/linux/blob/master/drivers/thunderbolt/eeprom.c
#
#           #define TB_DROM_DATA_START 13
#           struct tb_drom_header {
#               /* BYTE 0 */
#               u8 uid_crc8; /* checksum for uid */
#               /* BYTES 1-8 */
#               u64 uid;
#               /* BYTES 9-12 */
#               u32 data_crc32; /* checksum for data_len bytes starting at byte 13 */
#               /* BYTE 13 */
#               u8 device_rom_revision; /* should be <= 1 */
#               u16 data_len:10;
#               u8 __unknown1:6;
#               /* BYTES 16-21 */
#               u16 vendor_id;
#               u16 model_id;
#               u8 model_rev;
#               u8 eeprom_rev;
#           } __packed;
#           
#           enum tb_drom_entry_type {
#               /* force unsigned to prevent "one-bit signed bitfield" warning */
#               TB_DROM_ENTRY_GENERIC = 0U,
#               TB_DROM_ENTRY_PORT,
#           };
#           
#           struct tb_drom_entry_header {
#               u8 len;
#               u8 index:6;
#               bool port_disabled:1; /* only valid if type is TB_DROM_ENTRY_PORT */
#               enum tb_drom_entry_type type:1;
#           } __packed;
#           
#           struct tb_drom_entry_generic {
#               struct tb_drom_entry_header header;
#               u8 data[];
#           } __packed;
#           
#           struct tb_drom_entry_port {
#               /* BYTES 0-1 */
#               struct tb_drom_entry_header header;
#               /* BYTE 2 */
#               u8 dual_link_port_rid:4;            // "Dual-Link Port RID" 0 for the first Thunderbolt controller, 1 for the second Thunderbolt controller, 2 for ?
#               u8 link_nr:1;                       // "Lane" 0 for Lane 1, 1 for Lane 2
#               u8 unknown1:2;                      // 0
#               bool has_dual_link_port:1;          // 1
#           
#               /* BYTE 3 */
#               u8 dual_link_port_nr:6;             // "Dual-Link Port" 2,1,4,3 for ports 1,2,3,4
#               u8 unknown2:2;                      // 0
#           
#               /* BYTES 4 - 5 TODO decode */
#               u8 micro2:4;                        //                          0                0,1,2 (0 for first controller, 1 for second controller)
#               u8 micro1:4;                        //                          4                8
#               u8 micro3;                          // "Micro Address"          26,24            00,01
#                                                   // or "HPM Address"?
#           
#               /* BYTES 6-7, TODO: verify (find hardware that has these set) */
#               u8 peer_port_rid:4;                 // 0
#               u8 unknown3:3;                      // 0
#               bool has_peer_port:1;               // 0
#               u8 peer_port_nr:6;                  // 0
#               u8 unknown4:2;                      // 0
#           } __packed;
#
#
#
#
#
#           Macmini8,1
#
#           0x00) CRC8: 0x..								
#           0x01) UID: 0x000115CE05397601               Least significant byte is Thunderbolt Bus number (0,1,...)
#           0x09) CRC32c: 0x........
#           0x0d) Device ROM Revision: 1
#           0x0e) Length: 0x....
#           0x10) Vendor ID: 0x1                        two bytes;
#                                                       1 = Apple
#           0x12) Device ID: 0xD                        two bytes;
#                                                       16=MacPro7,1
#                                                       13=iMac19,1 or Macmini8,1
#                                                       12=iMac18,3 or iMacPro1,1
#                                                       11=MacBookPro11,5 // Thunderbolt 2
#           0x14) Device Revision: 0x1
#           0x15) EEPROM Revision: 0
#           0x16)   1: 8 1 0 2 8 1 00 0000              Thunderbolt Port
#           0x1e)   2: 9 1 0 1 8 1 00 0000              Thunderbolt Port
#           0x26)   3: 8 1 0 4 8 1 01 0000              Thunderbolt Port
#           0x2e)   4: 9 1 0 3 8 1 01 0000              Thunderbolt Port
#           0x36)   5: 0 9 0 1 0 0                      DP or HDMI Adapter (DP In Adapter) Sink 0
#           0x3b)   6: 0 9 0 1 0 0                      DP or HDMI Adapter (DP In Adapter) Sink 1
#           0x40)   7:                                  Thunderbolt NHI Adapter
#           0x42)   8: 2 0                              PCIe Adapter (PCI Down Adapter) @1 (3 bits PCI Device, 5 bits for ???)
#           0x45)   9: 8 0                              PCIe Adapter (PCI Down Adapter) @4
#           0x48) - A: 
#           0x4a) - B: 
#           0x4c)   1: "Apple Inc."
#           0x59)   2: "Macintosh"
#           0x65) End
#           
#           
#           MacBookPro11,5
#
#           0x01) UID: 0x0001001701C9F100				
#           0x0d) Device ROM Revision: 1
#           0x10) Vendor ID: 0x1
#           0x12) Device ID: 0xB
#           0x14) Device Revision: 0x1
#           0x15) EEPROM Revision: 1
#           0x16)   1: 8 0 0 2 8 0 00 0000				Thunderbolt Port 1, Dual Link Port, Lane 0, Dual-Link Port 2, Micro Address 0
#           0x1e)   2: 9 0 0 1 8 0 00 0000				Thunderbolt Port 2, Dual Link Port, Lane 1, Dual-Link Port 1, Micro Address 0 
#           0x26)   3: 8 0 0 4 8 0 01 0000				Thunderbolt Port 3, Dual Link Port, Lane 0, Dual-Link Port 4, Micro Address 1 
#           0x2e)   4: 9 0 0 3 8 0 01 0000				Thunderbolt Port 4, Dual Link Port, Lane 1, Dual-Link Port 3, Micro Address 1 
#           0x36)   5: 000000000000               		Thunderbolt NHI Adapter
#           0x3e)   6: 6 0                              PCIe Adapter (PCI Down Adapter) @3 (3 bits PCI Device, 5 bits for ???)
#           0x41)   7: 8 0                              PCIe Adapter (PCI Down Adapter) @4
#           0x44)   8: a 0                              PCIe Adapter (PCI Down Adapter) @5
#           0x47)   9: c 0                              PCIe Adapter (PCI Down Adapter) @6
#           0x4a) - A: 
#           0x4c)   B: 500082							DP or HDMI Adapter (DP In Adapter) Sink 0, Port Affinity 1,2, Preferred Null Port 2
#           0x51)   C: 500084							DP or HDMI Adapter (DP In Adapter) Sink 1, Port Affinity 3,4, Preferred Null Port 4
#           0x56)   1: "Apple Inc."
#           0x63)   2: "Macintosh"
#           0x6f) End
#           
#=========================================================================================
# Modify DROM


iasl_location=/Applications/MaciASL.app/Contents/MacOS/iasl-stable


getarrstart () {
	# bash arrays start at 0
	# zsh arrays start at 1 (applies only to [] syntax) but this can be changed with "setopt ksh_arrays"
	# zsh arrays start at 0 when using ${arr:x:x} syntax
	local arr=(1 0)
	arrstart=${arr[1]}
}
getarrstart


crc () {
	local bits=$(($1))
	local inputreflected=$(($2))
	local outputreflected=$(($3))
	local polynomial=$(($4))
	local crc=$(($5))
	local finalxor=$(($6))
	for data in $(xxd -p -c 1 | {
		if (( inputreflected )); then
			rev | tr '0123456789abcdef' '084c2a6e195d3b7f'
		else
			cat
		fi
	}); do
		((crc ^= (0x$data << (bits-8))))
		for ((i=0;i<8;i++)); do
            if ((crc >> (bits-1))); then
            	((crc = (crc << 1) ^ polynomial))
            else
            	((crc <<= 1))
        	fi
            ((crc &= ((1 << $bits)-1)))
        done
    done
	printf "%0$(((bits+3) / 4))x" $((crc ^ finalxor)) | {
		if (( outputreflected )); then
			rev | tr '0123456789abcdef' '084c2a6e195d3b7f'
		else
			cat
		fi
	}
}

crc8uid () {
	crc 8 0 0 7 0 0xdb
}

crc32c () {
	crc 32 1 1 0x1edc6f41 0xffffffff 0xffffffff
}


replacebytes () {
	local bytepos=$(($1*2))
	local thebytes=$2
	local thelen=${#thebytes}
	[[ -n $3 ]] && thelen=$(($3*2))
	thedrom=${thedrom:0:$bytepos}${thebytes}${thedrom:$bytepos+thelen}
}

processdrom () {
	(( debug )) && echo ": processdrom " "$@" 1>&2

	local dosetuid=0
	local dosetport=0
	local dosetstring=0
	local doportnumber=-1
	local dostringnumber=-1

	while (( $# )); do
		local param="$1"; shift
		if [[ $param != '-' ]]; then
			eval "local $param=1"
		fi
		case "$param" in
			dosetuid)
				local douuidnum=""
				douuidnum=$(perl -pe '$_="0000000000000000" . $_;s/[^A-Fa-f0-9]//g;s/.*(.{16})$/\1/' <<< "$1" | tr 'a-f' 'A-F') # make UID uppercase like Apple does
				shift
				local dotheuid=""
				dotheuid=$(tr 'A-F' 'a-f' <<< "${douuidnum:14:2}${douuidnum:12:2}${douuidnum:10:2}${douuidnum:8:2}${douuidnum:6:2}${douuidnum:4:2}${douuidnum:2:2}${douuidnum:0:2}")
				;;
			dosetport)
				local doportnumber="$(($1))"; shift
				local doportcontents="$1"; shift
				local doportdisable="$1"
				[[ $doportdisable = "-" || $doportdisable = "1" ]] && doportdisable=1 || doportdisable=0
				;;
			dodeleteport)
				local doportnumber="$(($1))"; shift
				;;
			dosetstring)
				local dostringnumber="$(($1))"; shift
				local dostringcontents="$1"; shift
				;;
			dodeletestring)
				local dostringnumber="$(($1))"; shift
				;;
		esac
	done

	thecrc8=$((0x${thedrom:0:2}))
	theuid=${thedrom:2:16}
	theuidnum=$(tr 'a-f' 'A-F' <<< "${thedrom:16:2}${thedrom:14:2}${thedrom:12:2}${thedrom:10:2}${thedrom:8:2}${thedrom:6:2}${thedrom:4:2}${thedrom:2:2}") # make UID uppercase like Apple does

	if [[ $dosetuid = 1 && $theuidnum != "$douuidnum" ]]; then
		replacebytes 1 "$dotheuid"
		theuid=$dotheuid
	fi

	theexpectedcrc8=$((0x$(xxd -p -r <<< "$theuid" | crc8uid)))
	(( theexpectedcrc8 != thecrc8 )) && {
		if (( dorepairchecksums )); then
			replacebytes 0 "$(printf "%02x" $theexpectedcrc8)"
			(( dodump )) &&  printf "0x00) CRC8: 0x%02x (changed: 0x%02x)\n" $thecrc8 $theexpectedcrc8
		else
			(( dodump )) &&  printf "0x00) CRC8: 0x%02x (expected: 0x%02x)\n" $thecrc8 $theexpectedcrc8
		fi
	}

	(( dodump )) && {
		printf "0x01) UID: 0x%s" "$theuidnum"
		if [[ $dosetuid = 1 && $theuidnum != "$douuidnum" ]]; then
			printf " (changed: 0x%s)" "$douuidnum"
		fi
		echo
	}

	thecrc32=$((0x${thedrom:24:2}${thedrom:22:2}${thedrom:20:2}${thedrom:18:2}))
	thedatalen=$((0x${thedrom:30:2}${thedrom:28:2} & 0x3ff))

	thedeviceromrevision=$((0x${thedrom:26:2}))
	(( dodump )) && printf "0x0d) Device ROM Revision: %d\n" $thedeviceromrevision

	theunknown=$(((0x${thedrom:30:2}${thedrom:28:2} & 0x3ff) >> 10))
	(( dodump && theunknown )) && printf "0x0e) Unknown: %d (expected 0)\n" $theunknown

	thevendorid=$((0x${thedrom:34:2}${thedrom:32:2}))
	(( dodump )) && printf "0x10) Vendor ID: 0x%X\n" $thevendorid

	themodelid=$((0x${thedrom:38:2}${thedrom:36:2}))
	(( dodump )) && printf "0x12) Device ID: 0x%X\n" $themodelid

	themodelrev=$((0x${thedrom:40:2}))
	(( dodump )) && printf "0x14) Device Revision: 0x%X\n" $themodelrev

	theeepromrev=$((0x${thedrom:42:2}))
	(( dodump )) && printf "0x15) EEPROM Revision: %d\n" $theeepromrev

	while ((1)); do
		local portoffset=22
		((thedataend = 13 + thedatalen))

		# Keep a list of ports and strings and generic data
		Ports=()
	
		while (( portoffset <= thedataend )); do
			[[ -z ${thedrom:$portoffset*2:2} ]] && break
	
			local portlen=$((0x${thedrom:$portoffset*2:2}))

			if ((portlen < 2)); then
				(( dodump && (portoffset != thedataend) )) && echo "Unexpected error: port length is < 2: $portoffset + $portlen <= $thedataend"
				break
			fi
			(( portoffset == thedataend )) && {
				(( dodump )) && echo "      ============== (following bytes are unexpected)"
				((thedataend += portlen))
			}

			local theporttype=$((0x${thedrom:$portoffset*2+2:2} >> 7)) # 0=generic,1=port
			local theportdisabled=$(((0x${thedrom:$portoffset*2+2:2} >> 6) & 1)) # 0=enabled,1=disabled
			local theportnumber=$((0x${thedrom:$portoffset*2+2:2} & 0x3f)) # 1..9,a..d
			local theportbytes=${thedrom:$portoffset*2+4:$portlen*2 - 4}
			local actualportlen=$((${#theportbytes} / 2 + 2))
		
			if (( dodump )); then
				printf "0x%02x) %s %X: " $portoffset "$( ((theportdisabled)) && printf "-" || printf " ")" $theportnumber
				if (( theporttype || theportnumber < 1 || theportnumber > 2 )); then
					printf "%s" "$theportbytes"
				else
					printf "\"%s\"" "$(perl -pE "s/(00)+$//" <<< "${theportbytes}" | xxd -p -r)"
					if [[ $(perl -pE "s/.*?((00)+)$/\1/" <<< "${theportbytes}") != "00" ]]; then
						printf " (expected single terminating null character: %s)" "$theportbytes"
					fi
				fi

				if (( !theporttype && theportdisabled )); then
					printf " (unexpectedly disabled)"
				fi
			fi

			if ((theportnumber <= 0)); then
				(( dodump )) && printf " (expected port number > 0)"
			elif ((theportnumber == (theporttype ? doportnumber : dostringnumber))); then
				((dodump)) && {
					((dosetport || dosetstring)) && printf " (replaced)" || printf " (removed)"
				}
			else
				Ports+=("$(printf "%d %02x %02x %s %s" $((1 - theporttype)) $theportnumber $portoffset $theportdisabled "$theportbytes")")
			fi
			
			if (( portoffset + portlen > thedataend )); then
				(( dodump )) && printf " (unexpected error: bytes exceeds expected end: 0x%02x + %d = 0x%02x > 0x%02x)" $portoffset $portlen $((portoffset + portlen)) "$thedataend"
			fi
			if (( portlen != actualportlen )); then
				(( dodump )) && printf " (unexpected error: too few remaining bytes: %d > %d)" $portlen $actualportlen
			fi
			(( dodump )) && echo

			((portoffset += actualportlen))
		done
	
		if (( doportnumber >= 0 || dostringnumber >= 0 )); then
			(( dosetport ))   && Ports+=( "$( printf "%d %02x %02x %s %s" 0 $doportnumber   0 "$doportdisable" "$doportcontents"                                       )" )
			(( dosetstring )) && Ports+=( "$( printf "%d %02x %02x %s %s" 1 $dostringnumber 0 "0"              "$(printf "%s\0" "$dostringcontents" | xxd -p -c 9999)" )" )
			local allportbytes=""
			allportbytes=$(
				IFS=$'\n'
				for theportstring in $(sort <<< "${Ports[*]}"); do
					printf "%02x%02x%s" $(( (${#theportstring} - 10) / 2 + 2 )) $(( ((1 - ${theportstring:0:1}) << 7) | (${theportstring:8:1} << 6) | (0x${theportstring:2:2} & 0x3f) )) "${theportstring:10}"
				done
			)
			replacebytes 22 "$allportbytes" ${#thedrom}
			((thedatalen = ${#allportbytes}/2 + 22 - 13 ))
			replacebytes 14 "$(printf "%04x" "$thedatalen" | sed -E 's/(..)(..)/\2\1/')"
			
			doportnumber=-1
			dostringnumber=-1
			(( dodump )) && echo "	  after changes:"
		else
			break
		fi
	done

	theexpectedcrc32=$((0x$(xxd -p -r <<< "${thedrom:26:$thedatalen*2}" | crc32c)))
	(( theexpectedcrc32 != thecrc32 )) && {
		if (( dorepairchecksums )); then
			replacebytes 9 "$(printf "%08x" $theexpectedcrc32 | sed -E 's/(..)(..)(..)(..)/\4\3\2\1/')"
			(( dodump )) &&  printf "0x09) CRC32: 0x%08x (changed: 0x%08x)\n" $thecrc32 $theexpectedcrc32
		else
			(( dodump )) &&  printf "0x09) CRC32: 0x%08x (expected: 0x%08x)\n" $thecrc32 $theexpectedcrc32
		fi
	}

	(( dodump )) && {
		printf "0x%02x) End" "$portoffset"
		if [[ -n $(tr -d '0' <<< "${thedrom:$portoffset*2}") ]]; then
			printf " (unexpected bytes: %s)" "${thedrom:$portoffset*2}"
		fi
		echo
	}

	if (( domake )); then

		IFS=$'\n'
		portoffset=22
		for theportstring in $(sort <<< "${Ports[*]}"); do
			portlen=$(( (${#theportstring} - 10) / 2 + 2 ))
			((portoffset += portlen))
		done
	
		printf '
	"ThunderboltDROM",
	Buffer (0x%X)
	{
		/* 0x00     */  0x%s,                                           // CRC8 checksum: 0x%02X
		/* 0x01     */  0x%s, 0x%s, 0x%s, 0x%s, 0x%s, 0x%s, 0x%s, 0x%s, // Thunderbolt Bus %d, UID: 0x%s
		/* 0x09     */  0x%s, 0x%s, 0x%s, 0x%s,                         // CRC32c checksum: 0x%08X
		/* 0x0D     */  0x%s,                                           // Device ROM Revision: %d
		/* 0x0E     */  0x%s, 0x%s,                                     // Length: %d (starting from previous byte)
		/* 0x10     */  0x%s, 0x%s,                                     // Vendor ID: 0x%X
		/* 0x12     */  0x%s, 0x%s,                                     // Device ID: 0x%X
		/* 0x14     */  0x%s,                                           // Device Revision: 0x%X
		/* 0x15     */  0x%s,                                           // EEPROM Revision: %d
' \
			$portoffset \
			"${thedrom:0:2}" $thecrc8 \
			"${thedrom:2:2}" "${thedrom:4:2}" "${thedrom:6:2}" "${thedrom:8:2}" "${thedrom:10:2}" "${thedrom:12:2}" "${thedrom:14:2}" "${thedrom:16:2}" $((0x${thedrom:2:2})) "$theuidnum" \
			"${thedrom:18:2}" "${thedrom:20:2}" "${thedrom:22:2}" "${thedrom:24:2}" $thecrc32 \
			"${thedrom:26:2}" $thedeviceromrevision \
			"${thedrom:28:2}" "${thedrom:30:2}" "$thedatalen" \
			"${thedrom:32:2}" "${thedrom:34:2}" $thevendorid \
			"${thedrom:36:2}" "${thedrom:38:2}" $themodelid \
			"${thedrom:40:2}" $themodelrev \
			"${thedrom:42:2}" $theeepromrev

		IFS=$'\n'
		portoffset=22
		for theportstring in $(sort <<< "${Ports[*]}"); do
			portlen=$(( (${#theportstring} - 10) / 2 + 2 ))
			theportnumber=$((0x${theportstring:2:2} & 0x3f))
			theportdisabled=${theportstring:8:1}
			theporttype=$((1 - ${theportstring:0:1}))
			printf "		/* 0x%02X %s %X */  0x%02x, 0x%02x, %s" $portoffset "$( ((theportdisabled)) && printf "-" || printf " " )" $theportnumber $portlen \
				$(( (theporttype << 7) | (theportdisabled << 6) | theportnumber )) \
				"$( perl -pE 's/(..)/0x\1, /g' <<< "${theportstring:10}" )"
			if (( theporttype == 0 )); then
				local thestring=""
				thestring="$(perl -pE "s/(00)+$//" <<< "${theportstring:10}" | xxd -p -r)"
				if (( theportnumber == 1 )); then
					printf '// Vendor Name: "%s"' "$thestring"
				elif (( theportnumber == 2 )); then
					printf '// Device Name: "%s"' "$thestring"
				else
					 printf '// "%s"' "${theportstring:10}"
				fi
			elif (( ${#theportstring} == 12 )); then
				printf '// PCIe xx:%02x.%x' $((0x${theportstring:10} >> 5)) $((0x${theportstring:10} & 0x1f)) #### fix this - function should only be 3 bits - therefore there are 2 unknown bits?
			fi
			printf "\n"
			((portoffset += portlen))
		done
		printf "	},\n"
	fi
}


repairchecksums () {
	processdrom dorepairchecksums
}

setuid () {
	processdrom dorepairchecksums dosetuid "$1"
}

setport () {
	processdrom dorepairchecksums dosetport "$@"
}

deleteport () {
	processdrom dorepairchecksums dodeleteport "$1"
}

setstring () {
	processdrom dorepairchecksums dosetstring "$@"
}

deletestring () {
	processdrom dorepairchecksums dodeletestring "$1"
}


#=========================================================================================
# Files from DROM


dumpdrom () {
	processdrom dodump
}

makedromdsl () {
	processdrom domake
}


makedromdslall () {
	local savedrom="$thedrom"
	local thefolderpath="$1"
	local i=""
	for ((i = 1 ; i <= ${#droms[@]} ; i++)); do
		usedromnum "$i"
		makedromdsl > "${thefolderpath:=.}/${thefilenamebase}_makedromdsl.txt"
	done
	usedromstring "$savedrom"
}


dumpdromall () {
	local i=""
	for ((i = 1 ; i <= ${#droms[@]} ; i++)); do
		echo "======================================="
		echo "$i)"
		usedromnum "$i"
		dumpdrom
	done
}


dumpdromalltofiles () {
	local savedrom="$thedrom"
	local thefolderpath="$1"
	local i=""
	for ((i = 1 ; i <= ${#droms[@]} ; i++)); do
		usedromnum "$i"
		dumpdrom > "${thefolderpath:=.}/${thefilenamebase}_dumpdrom.txt"
	done
	usedromstring "$savedrom"
}


#=========================================================================================
# Use DROM


cleardrominfo () {
	# clear anything here that is not cleared by processdrom
	:
}


usedromstring () {
	cleardrominfo
	(( debug )) && echo ": usedromstring $1" 1>&2
	thedrom="$1"
	processdrom
}


usedromnum () {
	cleardrominfo
	thedrom=${droms[arrstart - 1 + $1]}
	processdrom
	thefilenamebase="${thefilenamebase}_$i"
}


#=========================================================================================
# DROM List


cleardroms () {
	droms=()
	paths=()
}
cleardroms


adddrom () {
	local savedrom="$thedrom"
	local thepath="$1"
	usedromstring "$2"
	(( ignoreuid )) && replacebytes 0 188877665544332211

	local isnew=1
	local i=""
	for ((i = 0 ; i < ${#droms[@]} ; i++)); do
		if [[ $thedrom = "${droms[i+arrstart]}" ]]; then
			if [[ ! "$(printf "_\n%s\n_" "${paths[i+arrstart]}")" =~ $(printf ".*\n%s\n.*" "${thepath}") ]]; then
				paths[i+arrstart]="$(printf "%s\n%s" "${paths[i+arrstart]}" "$thepath")"
			fi
			isnew=0
			break
		fi
	done
	
	if (( isnew )); then
		(( debug )) && echo ": isnew" 1>&2
		droms+=("$thedrom")
		paths+=("$thepath")
	fi
	usedromstring "$savedrom"
}


numstrings=0
loadstring () {
	local sourcename="$2"
	if [[ -z $sourcename ]]; then
		((numstrings++))
		sourcename="string:$numstrings"
	fi
	adddrom "$sourcename" "$1"
}


loadhexfile () {
	adddrom "$1" "$(xxd -r "$1" | xxd -p -c 99999)"
}


loadonedromitem () {
	local dromitem="$1"
	local thepath="${dromitem% = <*}"
	local thedrom="${dromitem##* = <}"
	local thedrom="${thedrom%>}"
	(( debug )) && echo ":" adddrom "${thepath}" "${thedrom}" 1>&2
	adddrom "${thepath}" "${thedrom}"
}


loadfwfile () {
	while (( $# )); do
		local thefilename="$1"
		shift
		IFS=$'\n'
		for dromitem in $(
			xxd -p -c 9999999999 "$thefilename" | perl -e '
				while (<>) {
					s/(..)/\1 /g;
					
					$start = 0;
					foreach my $offset (0, 4096 * 3) {
						$start = hex(substr($_, $offset, 11) =~ s/(..) (..) (..) (..)/$4$3$2$1/r);
						last if ($start != hex("ffffffff"));
					}

					# look for DROM
					while ( /(?{$X=pos()})44 52 4f 4d 20 20 20 20 ff ff ff ff ff ff ff ff ((.. ){1008})(?{$Y=pos()})/g ) {
						$X /= 3;
						$thedrom=$1;
						$thedrom =~ s/(ff )*$//g;
						$thedrom =~ s/ //g;
						$version = "vers_unknown";
						if ($X == hex(200)) {
							$version = "v" . substr($_, (10) * 3, 2);
							$partition = "linux";
						} elsif ($X < hex(4000)) {
							$partition = "missing header";
						} elsif ($X < hex(82000)) {
							$version = "v" . substr($_, (hex(4000) + 10) * 3, 2);
							if ($start == hex(4000)) {
								$partition = "active";
							} elsif ($start == hex(82000)) {
								$partition = "inactive";
							} else {
								$partition = "unknown start";
							}
						} elsif ($X < hex(100000)) {
							$version = "v" . substr($_, (hex(82000) + 10) * 3, 2);
							if ($start == hex(4000)) {
								$partition = "inactive";
							} elsif ($start == hex(82000)) {
								$partition = "active";
							} else {
								$partition = "unknown start";
							}
						} else {
							$partition = "rom too large";
						}
						pos() = $Y;
						$nvmversion = "nvm_unknown";
						
						# get nvm version from after EE_PCIE
						if ( /(?{$Z=pos()})45 45 5f 50 43 49 45 20 (?:ff ){8}(?:.. )*?(..) (..) (..) (..) (?:.. ){4}(?:ff ){8}(?{$W=pos()})/g ) {
							pos() = $W;
							# need to find out what all the digits are for - I am just guessing here:
							$nvmversion="nvm_v" . (( $2 . $1 . "." . $3 . $4 ) =~ s/0*([^.]*.)\.0*(.+)/\1.\2/r );
						}
						else
						{
							pos() = $Y;
						}
						printf ("%s:%s:%s:%s:0x%x = <%s>\n", "'"${thefilename}"'", $partition, $version, $nvmversion, $X, $thedrom);
					}
				}
			'
		); do
			(( debug )) && echo ":" loadonedromitem "${dromitem}" 1>&2
			loadonedromitem "${dromitem}"
		done
	done
}


loadonedslfile () {
	local thefilename="$1"
	local thesource="$2"
	[[ -z $thesource ]] && thesource="$thefilename"
	
	#
	#	LeadNameChar := [A-Za-z_]
	#	DigitChar := [0-9]
	#	NameChar := [A-Za-z_0-9]
	#	RootChar := \
	#	ParentPrefixChar := ^
	#	PathSeparatorChar := .
	#
	#	// Names and paths
	#
	#	NameSeg := [A-Za-z_][A-Za-z_0-9]{0,3}
	#
	#	PrefixPath := \^*
	#
	#	NamePathTail := ([.][A-Za-z_][A-Za-z_0-9]{0,3})*
	#
	#	NamePath := (([A-Za-z_][A-Za-z_0-9]{0,3}([.][A-Za-z_][A-Za-z_0-9]{0,3})*)|)
	#
	#	NonEmptyNamePath := [A-Za-z_][A-Za-z_0-9]{0,3}([.][A-Za-z_][A-Za-z_0-9]{0,3})*
	#
	#	NameString := ([\\]|\^+|)(([A-Za-z_][A-Za-z_0-9]{0,3}([.][A-Za-z_][A-Za-z_0-9]{0,3})*)|)
	#				| [A-Za-z_][A-Za-z_0-9]{0,3}([.][A-Za-z_][A-Za-z_0-9]{0,3})*
	#

	IFS=$'\n'
	for dromitem in $(
		perl -e '
			use strict;

			my $line3 = "";
			my $line2 = "";
			my $line1 = "";

			my %paths = ( "\\" => 1 );

			sub addline {
				$line3 = $line2;
				$line2 = $line1;
				$line1 = $_[0];
			}

			sub group {
				my $indent = $_[0];
				my $codepath = $_[1];
				my $acpipath = $_[2];

				my $nextacpipath = $acpipath;
				my $nextcodepath = $codepath;
	
				my $dodump = 0;
				my $buffersize = 0;
	
				if ( $line2 =~ /"ThunderboltDROM",\s*$/) {
					$dodump = 1;
					if ( $line1 =~ /^\s*Buffer\s*\(0x([0-9A-F]+)\)/ ) {
						$buffersize = hex($1);
					}
					elsif ( $line1 =~ /^\s*Buffer\s*\(One\)/ ) {
						$buffersize = 1;
					}
					elsif ( $line1 =~ /^\s*Buffer\s*\(Zero\)/ ) {
						$buffersize = 0;
					}
					else {
						$dodump = 0;
					}
				}
	
				if ( $dodump == 1 ) {
					print "'"$thesource"':" . $acpipath . ":ThunderboltDROM = <";
				}

				while (<>) {
					s/\s*\/\/.*//;                        # single line // comment
					s/\s*\/\*.*?\*\/\s*//g;               # single line /* */ comment
					s/\s*(.*?)\s*$/\1/g;                  # remove indents and trailing spaces
					if (/^\/\*.*/ .. /^.*?\*\/.*/) { }    # multi line comment
					elsif ( /^$/ ) { }                    # skip blank lines
					elsif ( /^{$/ ) {
						group($indent . "\t", $nextcodepath, $nextacpipath);
					}
					elsif ( /^}/ ) {
						if ( $dodump == 1 ) {
							if ($buffersize < 0) {
								print STDERR "Buffer size is too small\n";
							}
							elsif ($buffersize > 0) {
								print "00"x$buffersize;
							}
							print ">\n";
							$dodump = 0;
						}
						last;
					}
					else {
						addline($_);
						if ( /(External|Device|Field|Method|Name|Scope)\s*\(\s*([\\]|\^+|)(([A-Za-z_][A-Za-z_0-9]{0,3}([.][A-Za-z_][A-Za-z_0-9]{0,3})*)|)/ ) {
							my $command = $1;
							my $prefix = $2; # \ or ^+ or empty
							my $nameparts = $3;
							$nameparts =~ s/([A-Za-z0-9])_+/\1/g; # remove trailing spaces
							#print "nameparts:" . $nameparts . "\n";
							
							if ( $prefix =~ /\\/ ) {
								# absolute path
								$nextacpipath = $prefix . $nameparts;
							}
							elsif ( $prefix =~ /\^+/ ) {
								# parent path - remove from the current path a number of parents equal to the number of ^ characters
								my $pattern = "(.*?)([\\\\.][^.]+){0," . length($prefix) . "}\$";
								# empty path means root "\"
								$nextacpipath = ($acpipath =~ s/$pattern/\1/r =~ s/^$/\\/r) . "$nameparts";
							}
							else {
								# assume path is current path appended with name
								$nextacpipath = (($acpipath . "." . $nameparts) =~ s/^\\\./\\/r); # "\." is "\"
								if ( ($command eq "Scope") && ($nameparts =~ /[^.]+/) && !($paths{$nextacpipath}) ) {
									# For Scope, if path does not exist...
									if ( ($acpipath . ".") =~ /(.*[.\\]$nameparts)[.].*/ ) {
										# if current path includes names then set scope to parent that ends at name
										$nextacpipath = (($acpipath . ".") =~ s/(.*[.\\]$nameparts)[.].*/\1/r)
									} else {
										# unknown path - assume it exists
										print STDERR "unknown path " . $nextacpipath . "\n";
										#print STDERR "$_\n" for keys %paths;
									}
								}
							}
							# code path is just current path appended with entire prefix/nameparts (no interpretation of prefix characters or scoping)
							$nextcodepath = (($codepath . "." . $prefix . $nameparts) =~ s/^\\\./\\/r =~ s/\\\\/\\/r); # "\." is "\" and "\\" is "\"
							if ( !$paths{$nextacpipath} ) {
								# keep a list of all paths
								$paths{$nextacpipath} = 1;
							}
						}
						else {
							$nextacpipath = $acpipath;
							$nextcodepath = $codepath;
				
							if ( $dodump == 1 ) {
								my $outline = ($line1 =~ s/0x//gr =~ s/[, ]//gr);
								print $outline;
								$buffersize -= length($outline) / 2;
							}
						}
					}
				}
			}

			group("", "\\", "\\");
			# print "$_\n" for keys %paths;
		' < "$thefilename"
	); do
		(( debug )) && echo ":" loadonedromitem "${dromitem}" 1>&2
		loadonedromitem "${dromitem}"
	done
}


loaddslfile () {
	while (( $# )); do
		local thefilename="$1"
		shift
		loadonedslfile "$thefilename"
	done
}


loadamlfile () {
	[[ -f $iasl_location ]] || {
		echo "# Update iasl_location" 1>&2
		exit 1
	}

	thedirname=$(mktemp -d /tmp/aml.XXXXXX) || exit 1
	while (( $# )); do
		local thefilename="$1"
		shift
		if "$iasl_location" -p "$thedirname/xxx" "$thefilename" > /dev/null 2> "$thedirname/out.txt"; then
			loadonedslfile "$thedirname/xxx.dsl" "$thefilename"
		else
			cat "$thedirname/out.txt" 1>&2
		fi
	done
}


loadoneioregfile () {
	local thefilename="$1"
	local thesource="$2"
	[[ -z $thesource ]] && thesource="$thefilename"

	IFS=$'\n'
	for dromitem in $(
		perl -e '
			$thepath=""; while (<>) {
				if ( /^([ |]*)\+\-o (.+)  </ ) { $indent = (length $1) / 2; $name = $2; $thepath =~ s|^((/[^/]*){$indent}).*|$1/$name| }
				if ( /^[ |]*"(ThunderboltDROM)" = <(.*)>/i ) { print "'"${thesource}"'" . ":" . $thepath . "/" . $1 . " = <" . $2 . ">\n" }
			}
		' < "${thefilename}"
	); do
		loadonedromitem "${dromitem}"
	done
}


loadioregfile () {
	while (( $# )); do
		local thefilename="$1"
		shift
		loadoneioregfile "$thefilename"
	done
}


loadioreg () {
	local tmpfilename=""
	tmpfilename=$(mktemp /tmp/local_ioreg.XXXXXX) || exit 1
	ioreg -lw0 > "$tmpfilename"
	loadoneioregfile "$tmpfilename" "ioreg"
}


listdroms () {
	local savedrom="$thedrom"
	local i=""
	for ((i = 1 ; i <= ${#droms[@]} ; i++)); do
		usedromnum "$i"
	
		echo "$i)"
		echo "thedrom=$thedrom"
		echo "sources:"
		echo "${paths[i+arrstart-1]}"
		echo
	done
	usedromstring "$savedrom"
}


#=========================================================================================
# Misc


extractfwfromexe () {
	while (( $# )); do
		local thefilename="$1"
		shift
		perl -0777 -e '
			while (<>) {
				#printf "file:%s\n", $ARGV;
				@files = ( /\0([^\0]+.bin)(?=\0)/g );
				$filenum = 0;
				while ( /(?{$x=pos()})DROM(?{$y=pos()})/g ) {
					$sb = substr $_, $x - 0x4200 - 4, 4;
					$size = (ord(substr $sb, 3, 1) << 24) | (ord(substr $sb, 2, 1) << 16) | (ord(substr $sb, 1, 1) << 8) | ord (substr $sb, 0, 1);
					$filename = @files[$filenum];
					if ( $filename =~ /^$/ ) { $filename = "fw.bin"; }
					$dir = sprintf "%s/%02d", `dirname "$ARGV"` =~ s/\n$//r, $filenum;
					`mkdir -p "$dir"`;
					open(FH, ">", "$dir/$filename") or die $!;
					print FH substr $_, $x - 0x4200, $size;
					close(FH);
					pos() = $y;
					$filenum++;
				}
			}
		' "$thefilename"
	done
}


#=========================================================================================
# Help

dromhelp () {
	echo $'
Commands:
	Get DROM
		loadioreg
		loadstring hexstring [sourcename]
		loadfwfile filepath...
		loadamlfile filepath...
		loaddslfile filepath...
		loadioregfile filepath...
		loadhexfile filepath # for reverses xxd
		listdroms
		cleardroms

	Use DROM
		usedromnum numberfromlist
		usedromstring lowercasehexstring

	Modify DROM
		repairchecksums
		replacebytes bytepos lowercasehexstring [numbytestoreplace]
		setuid newuid
		setport 0xportnumber portcontents [-]
		deleteport 0xportnumber
		setstring 0xstringnumber stringvalue
		deletestring 0xstringnumber

	Files from DROM
		dumpdrom
		makedromdsl
		makedromdslall [folderpath]
		dumpdromall
		dumpdromalltofiles [folderpath]
	
	Misc
		extractfwfromexe exepath... # $(grep -l --include \'*.exe\' -R \'DROM\' . )

	Variables
		dodump # Set to 1 to dump the DROM while changes are made to the DROM.
		debug # Set to 1 to output debugging info (uses stderr)
		ignoreuid # Set to 1 to replace all uids with 0x1122334455667788.
		          # DROMs with the same contents except UID will be considered identical.

	Help
		dromhelp
'
}

#dromhelp


#=========================================================================================