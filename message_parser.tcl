proc parse_message {input_string} {

    set spliterator [string index $input_string 0]
    if {$spliterator != "#"} {
        return "Invalid spliterator: $spliterator"
    }

    set parts [split $input_string $spliterator]
    set type [lindex $parts 1]
    set data [lindex $parts 2]

    switch $type {
        "M" {
            return "Message: $data"
        }
        "SD" {
            # split data fields by semicolon
            set fields [split $data ";"]
            if {[llength $fields] != 10} {
                puts "Invalid number of fields: [llength $fields]"
                return;
            }
        
            set date [parse_date [lindex $fields 0]]
            set time [parse_time [lindex $fields 1]]
            set latitude [convert_latitude [lrange $fields 2 3]]
            set longitude [convert_longitude [lrange $fields 4 5]]
            set speed [validate_integer [lindex $fields 6]]
            set course [validate_integer [lindex $fields 7]]
            set height [validate_integer [lindex $fields 8]]
            set satellites [validate_integer [lindex $fields 9]]

            puts "SD packet:"
            puts "  Date: [lindex $date 0]-[lindex $date 1]-[lindex $date 2]"
            puts "  Time: [lindex $time 0]:[lindex $time 1]:[lindex $time 2]"
            puts "  Latitude: [lindex $latitude 0]° [lindex $latitude 1]'[lindex $latitude 2]\" [lindex $latitude 3]"
            puts "  Longitude: [lindex $longitude 0]° [lindex $longitude 1]'[lindex $longitude 2]\" [lindex $longitude 3]"
            puts "  Speed: $speed km/h"
            puts "  Course: $course degrees"
            puts "  Height: $height meters"
            puts "  Satellites: $satellites"

            return $date $time $latitude $longitude $speed $course $height $satellites
        }
        default {
            puts "Invalid type: $type"
            return;
        }
    }
}

# parse UTC date, formatted DDMMYYYY
proc parse_date {date} {
    if {[regexp {([0-9]{2})([0-9]{2})([0-9]{4})} $date - day month year]} {
        if {$day > 31 || $day < 1} {
            puts "Invalid day: $day"
            return;
        }
        if {$month > 12 || $month < 1} {
            puts "Invalid month: $month"
            return;
        }
        if {$month == 2 && $day > 29} {
            puts "Invalid day for February: $day"
            return;
        }

        return [list $year $month $day]
    } else {
        puts "Invalid date format: $date"
        return;
    }
}

# parse UTC time, formatted HHMMSS
proc parse_time {time} {
    if {[regexp {([0-9]{2})([0-9]{2})([0-9]{2})} $time - hour minute second]} {
        if {$hour > 23 || $hour < 0} {
            puts "Invalid hour: $hour"
            return;
        }
        if {$minute > 59 || $minute < 0} {
            puts "Invalid minute: $minute"
            return;
        }
        if {$second > 59 || $second < 0} {
            puts "Invalid second: $second"
            return;
        }
        return [list $hour $minute $second]
    } else {
        puts "Invalid time format: $time"
        return;
    }
}

# Convert latitude from list of two elements
# first - number formatted DDMM.MMMM
# second - direction, either N or S
proc convert_latitude {latitude} {
    # parse latitude to degrees, minutes and decimal
    if {[regexp {([0-9]{2})([0-9]{2}).([0-9]{4})} [lindex $latitude 0] - degrees minutes decimal]} {
        set latitude_direction [lindex $latitude 1]
        # validate direction
        if {$latitude_direction == "S" || $latitude_direction == "N"} {
            return [list $degrees $minutes $decimal $latitude_direction]
        } else {
            puts "Invalid latitude direction: $latitude_direction"
            return;
        }
        if {$degrees > 90 || $degrees < 0} {
            puts "Invalid degrees: $degrees"
            return;
        }
    } else {
        puts "Invalid latitude format: $degrees° $minutes' $decimal\" $latitude_direction"
        return;
    }
}

# Convert longitude from list of two elements
# first - number formatted DDMM.MMMM
# second - direction, either E or W
proc convert_longitude {longitude} {
    # parse longitude to degrees, minutes and decimal
    if {[regexp {([0-9]{2})([0-9]{2}).([0-9]{4})} [lindex $longitude 0] - degrees minutes decimal]} {
        set longitude_direction [lindex $longitude 1]
        # validate direction
        if {$longitude_direction != "W" && $longitude_direction != "E"} {
            puts "Invalid longitude direction $longitude_direction"
            return;
        }
        if {$degrees > 90 || $degrees < 0} {
            puts "Invalid degrees: $degrees"
            return;
        }
    } else {
        puts "Invalid longitude format: $degrees° $minutes' $decimal\" $longitude_direction"
        return;
    }

    return [list $degrees $minutes $decimal $longitude_direction]
}

proc validate_integer {int} {
    if {[regexp {^([0-9]+)$} $int - integer]} {
        return $integer
    } else {
        puts "Invalid integer number: $int"
        return;
    }
}

puts [parse_message "#MHello world"]
puts [parse_message "#M#Cargo delievered"]
puts [parse_message "#SD#04012011;135515;5544.6025;N;3739.6834;E;35;215;110;7"]
puts [parse_message "#SD#48012011;135515;5544.6025;N;3739.6834;E;35;215;110;7"]
puts [parse_message "#SD#04012011;138015;5544.602599;N;3739.6834;N;35;215;110;7"]
puts [parse_message "#SD#04012011;138015;5544.6025;N;3739.6834;N;35;215;110;7"]
puts [parse_message "#SD#04012011;135515;5544.6025;N;3739.6834;E;35;215;110.5;7"]
puts [parse_message "#SD#04012011;135515;5544.6025;N;3739.6834;E;35;215"]
puts [parse_message "#SD#04012011;135515;5544.6025;N;3739.6834;E;35;215;110;7;99"]