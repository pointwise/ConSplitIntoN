#############################################################################
#
# (C) 2021 Cadence Design Systems, Inc. All rights reserved worldwide.
#
# This sample script is not supported by Cadence Design Systems, Inc.
# It is provided freely for demonstration purposes only.
# SEE THE WARRANTY DISCLAIMER AT THE BOTTOM OF THIS FILE.
#
#############################################################################
 
###############################################################################
##
## ConSplitIntoN.glf
##
## Script with Tk interface to split a connector into N connectors
##
###############################################################################

package require PWI_Glyph 2

pw::Script loadTk


############################################################################
# showTitle: add a title label
############################################################################
proc showTitle { f } {
  pack [frame $f.title] -side top -expand FALSE -fill x
  pack [label $f.title.label -text "Split Connectors" -justify center] \
    -side top -fill y -pady 5
  pack [frame $f.title.hr -height 2 -relief sunken -borderwidth 1] \
    -side top -fill x

  set font [$f.title.label cget -font]
  set fontFamily [font actual $font -family]
  set fontSize [font actual $font -size]
  set bigLabelFont [font create -family $fontFamily -weight bold \
    -size [expr {int(1.5 * $fontSize)}]]
  $f.title.label configure -font $bigLabelFont

  wm title . "Split Connectors"
}

############################################################################
# showEndMessage: display a message and quit
############################################################################
proc showEndMessage { msg } {
  wm iconify .
  tk_messageBox -type ok -message $msg
  exit
}

############################################################################
# checkSplitsInput: validate input
############################################################################
proc checkSplitsInput { w var okbut text } {
  if {![string is integer -strict $text] || $text < 2} {
    set okay 0
  } else {
    set okay 1
  }

  if {0 != $okay && $var > 0 && $text > [expr {$var - 1}]} {
    set okay 0
  }
  if {0 == $okay} {
    $w configure -bg "#FFCCCC"
    $okbut configure -state disabled
  } else {
    $w configure -bg "#FFFFFF"
    $okbut configure -state normal
  }
  return true
}

############################################################################
# doSplit: split the given cons into the requested number of pieces
############################################################################
proc doSplit { cons nPieces } {
  set newCons $cons
  foreach con $cons {
    set dim [$con getDimension]
    if { $dim > $nPieces || $dim == 0 } {
      # split the connector at even delta-S values
      set dS [list]
      for {set nParam 1} {$nParam < $nPieces} {incr nParam} { 
        lappend dS [$con getParameter -closest \
          [$con getXYZ -arc [expr $nParam * 1.0 / $nPieces]]]
      }
      set newcon [$con split $dS]

      # re-distribute points for dimensioned connectors
      if { 0 < $dim } {
        set newdim [expr [expr $dim + $nPieces - 1] / $nPieces ]
        set remainder [expr ($dim + $nPieces - 1) % $nPieces]
      
        foreach x $newcon {
          if { $newdim > 2 } {
            $x setDimension $newdim
          } else {
            $x setDimension 2
          }
        }
        set i 0
        while { $remainder > 0 } {
          [lindex $newcon $i] setDimension [expr $newdim + 1]
          incr i
          incr remainder -1
        }
      }
    }
  }
  exit
}

############################################################################
# pickCons: select connectors to split
############################################################################
proc pickCons { } {
  set conMask [pw::Display createSelectionMask -requireConnector {} \
    -blockConnector {Pole}]
  pw::Display selectEntities -selectionmask $conMask \
    -description "Select connector(s) to split equally" results

  set cons $results(Connectors)

  if {[llength $cons] == 0} {
    exit
  }

  return $cons
}

############################################################################
# makeWindow: make the Tk interface
############################################################################
proc makeWindow { } {
  global cons
  set minDim -1
  foreach con $cons {
    if {[catch {$con getDimension} dim]} {
      showEndMessage "$con is not a valid connector"
    }
    if {$minDim == -1 || $dim < $minDim} {
      set minDim $dim
    }
  }

  if {$minDim == 2} {
    showEndMessage [join [list \
      "At least one of the connectors chosen has" \
      "a dimension of 2 and can not be split."] "\n"]
  }

  # create GUI to select the number of points.
  if {0 == $minDim} {
    set nPieces 2
    set msg [join [list \
      "Enter the number of equal length connectors into" \
      "which each selected connector will be split:"] "\n"]
  } else {
    set nPieces [expr {$minDim - 1}]
    set msg [join [list \
      "Enter the number of equal length connectors" \
      "into which each selected connector will" \
      "be split (maximum is $nPieces):"] "\n"]
  }

  pack [frame .f]
  showTitle .f
  pack [label .f.t -text $msg] \
    -side top -expand true -fill both -padx 15 -pady 15
  pack [entry .f.i -width 10 -textvariable nPieces] \
    -side top -expand false -pady 5
  pack [frame .f.hr -height 2 -relief sunken -borderwidth 1] -side top -fill x
  pack [frame .f.bf] -expand true -fill x -pady 10

  pack [label .f.bf.logo -image [cadenceLogo] -bd 0 -relief flat] \
      -side left -padx 5

  pack [button .f.bf.cancel -text "Cancel" -command exit] -side right -padx 5
  pack [button .f.bf.ok -text "OK" -command {doSplit $cons $nPieces}] \
    -side right -padx 5

  .f.i configure -validate key \
    -validatecommand "checkSplitsInput %W $minDim .f.bf.ok %P"

  bind . <KeyPress-Escape> { .f.bf.cancel invoke }
  bind . <Control-KeyPress-Return> { .f.bf.ok invoke }

  ::tk::PlaceWindow . widget
}

proc cadenceLogo {} {
  set logoData "
R0lGODlhgAAYAPQfAI6MjDEtLlFOT8jHx7e2tv39/RYSE/Pz8+Tj46qoqHl3d+vq62ZjY/n4+NT
T0+gXJ/BhbN3d3fzk5vrJzR4aG3Fubz88PVxZWp2cnIOBgiIeH769vtjX2MLBwSMfIP///yH5BA
EAAB8AIf8LeG1wIGRhdGF4bXD/P3hwYWNrZXQgYmVnaW49Iu+7vyIgaWQ9Ilc1TTBNcENlaGlIe
nJlU3pOVGN6a2M5ZCI/PiA8eDp4bXBtdGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1w
dGs9IkFkb2JlIFhNUCBDb3JlIDUuMC1jMDYxIDY0LjE0MDk0OSwgMjAxMC8xMi8wNy0xMDo1Nzo
wMSAgICAgICAgIj48cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudy5vcmcvMTk5OS8wMi
8yMi1yZGYtc3ludGF4LW5zIyI+IDxyZGY6RGVzY3JpcHRpb24gcmY6YWJvdXQ9IiIg/3htbG5zO
nhtcE1NPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvbW0vIiB4bWxuczpzdFJlZj0iaHR0
cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL3NUcGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh
0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0idX
VpZDoxMEJEMkEwOThFODExMUREQTBBQzhBN0JCMEIxNUM4NyB4bXBNTTpEb2N1bWVudElEPSJ4b
XAuZGlkOkIxQjg3MzdFOEI4MTFFQjhEMv81ODVDQTZCRURDQzZBIiB4bXBNTTpJbnN0YW5jZUlE
PSJ4bXAuaWQ6QjFCODczNkZFOEI4MTFFQjhEMjU4NUNBNkJFRENDNkEiIHhtcDpDcmVhdG9yVG9
vbD0iQWRvYmUgSWxsdXN0cmF0b3IgQ0MgMjMuMSAoTWFjaW50b3NoKSI+IDx4bXBNTTpEZXJpZW
RGcm9tIHN0UmVmOmluc3RhbmNlSUQ9InhtcC5paWQ6MGE1NjBhMzgtOTJiMi00MjdmLWE4ZmQtM
jQ0NjMzNmNjMWI0IiBzdFJlZjpkb2N1bWVudElEPSJ4bXAuZGlkOjBhNTYwYTM4LTkyYjItNDL/
N2YtYThkLTI0NDYzMzZjYzFiNCIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g
6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/PgH//v38+/r5+Pf29fTz8vHw7+7t7Ovp6Ofm5e
Tj4uHg397d3Nva2djX1tXU09LR0M/OzczLysnIx8bFxMPCwcC/vr28u7q5uLe2tbSzsrGwr66tr
KuqqainpqWko6KhoJ+enZybmpmYl5aVlJOSkZCPjo2Mi4qJiIeGhYSDgoGAf359fHt6eXh3dnV0
c3JxcG9ubWxramloZ2ZlZGNiYWBfXl1cW1pZWFdWVlVUU1JRUE9OTUxLSklIR0ZFRENCQUA/Pj0
8Ozo5ODc2NTQzMjEwLy4tLCsqKSgnJiUkIyIhIB8eHRwbGhkYFxYVFBMSERAPDg0MCwoJCAcGBQ
QDAgEAACwAAAAAgAAYAAAF/uAnjmQpTk+qqpLpvnAsz3RdFgOQHPa5/q1a4UAs9I7IZCmCISQwx
wlkSqUGaRsDxbBQer+zhKPSIYCVWQ33zG4PMINc+5j1rOf4ZCHRwSDyNXV3gIQ0BYcmBQ0NRjBD
CwuMhgcIPB0Gdl0xigcNMoegoT2KkpsNB40yDQkWGhoUES57Fga1FAyajhm1Bk2Ygy4RF1seCjw
vAwYBy8wBxjOzHq8OMA4CWwEAqS4LAVoUWwMul7wUah7HsheYrxQBHpkwWeAGagGeLg717eDE6S
4HaPUzYMYFBi211FzYRuJAAAp2AggwIM5ElgwJElyzowAGAUwQL7iCB4wEgnoU/hRgIJnhxUlpA
SxY8ADRQMsXDSxAdHetYIlkNDMAqJngxS47GESZ6DSiwDUNHvDd0KkhQJcIEOMlGkbhJlAK/0a8
NLDhUDdX914A+AWAkaJEOg0U/ZCgXgCGHxbAS4lXxketJcbO/aCgZi4SC34dK9CKoouxFT8cBNz
Q3K2+I/RVxXfAnIE/JTDUBC1k1S/SJATl+ltSxEcKAlJV2ALFBOTMp8f9ihVjLYUKTa8Z6GBCAF
rMN8Y8zPrZYL2oIy5RHrHr1qlOsw0AePwrsj47HFysrYpcBFcF1w8Mk2ti7wUaDRgg1EISNXVwF
lKpdsEAIj9zNAFnW3e4gecCV7Ft/qKTNP0A2Et7AUIj3ysARLDBaC7MRkF+I+x3wzA08SLiTYER
KMJ3BoR3wzUUvLdJAFBtIWIttZEQIwMzfEXNB2PZJ0J1HIrgIQkFILjBkUgSwFuJdnj3i4pEIlg
eY+Bc0AGSRxLg4zsblkcYODiK0KNzUEk1JAkaCkjDbSc+maE5d20i3HY0zDbdh1vQyWNuJkjXnJ
C/HDbCQeTVwOYHKEJJwmR/wlBYi16KMMBOHTnClZpjmpAYUh0GGoyJMxya6KcBlieIj7IsqB0ji
5iwyyu8ZboigKCd2RRVAUTQyBAugToqXDVhwKpUIxzgyoaacILMc5jQEtkIHLCjwQUMkxhnx5I/
seMBta3cKSk7BghQAQMeqMmkY20amA+zHtDiEwl10dRiBcPoacJr0qjx7Ai+yTjQvk31aws92JZ
Q1070mGsSQsS1uYWiJeDrCkGy+CZvnjFEUME7VaFaQAcXCCDyyBYA3NQGIY8ssgU7vqAxjB4EwA
DEIyxggQAsjxDBzRagKtbGaBXclAMMvNNuBaiGAAA7"

  return [image create photo -format GIF -data $logoData]
}

set cons [pickCons]
makeWindow
tkwait window .

#############################################################################
#
# This file is licensed under the Cadence Public License Version 1.0 (the
# "License"), a copy of which is found in the included file named "LICENSE",
# and is distributed "AS IS." TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE
# LAW, CADENCE DISCLAIMS ALL WARRANTIES AND IN NO EVENT SHALL BE LIABLE TO
# ANY PARTY FOR ANY DAMAGES ARISING OUT OF OR RELATING TO USE OF THIS FILE.
# Please see the License for the full text of applicable terms.
#
#############################################################################

