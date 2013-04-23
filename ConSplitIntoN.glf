#
# Copyright 2009 (c) Pointwise, Inc.
# All rights reserved.
# 
# This sample Pointwise script is not supported by Pointwise, Inc.
# It is provided freely for demonstration purposes only.  
# SEE THE WARRANTY DISCLAIMER AT THE BOTTOM OF THIS FILE.
#
 
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

  pack [label .f.bf.logo -image [pwLogo] -bd 0 -relief flat] \
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

proc pwLogo {} {
  set logoData "
R0lGODlheAAYAIcAAAAAAAICAgUFBQkJCQwMDBERERUVFRkZGRwcHCEhISYmJisrKy0tLTIyMjQ0
NDk5OT09PUFBQUVFRUpKSk1NTVFRUVRUVFpaWlxcXGBgYGVlZWlpaW1tbXFxcXR0dHp6en5+fgBi
qQNkqQVkqQdnrApmpgpnqgpprA5prBFrrRNtrhZvsBhwrxdxsBlxsSJ2syJ3tCR2siZ5tSh6tix8
ti5+uTF+ujCAuDODvjaDvDuGujiFvT6Fuj2HvTyIvkGKvkWJu0yUv2mQrEOKwEWNwkaPxEiNwUqR
xk6Sw06SxU6Uxk+RyVKTxlCUwFKVxVWUwlWWxlKXyFOVzFWWyFaYyFmYx16bwlmZyVicyF2ayFyb
zF2cyV2cz2GaxGSex2GdymGezGOgzGSgyGWgzmihzWmkz22iymyizGmj0Gqk0m2l0HWqz3asznqn
ynuszXKp0XKq1nWp0Xaq1Hes0Xat1Hmt1Xyt0Huw1Xux2IGBgYWFhYqKio6Ojo6Xn5CQkJWVlZiY
mJycnKCgoKCioqKioqSkpKampqmpqaurq62trbGxsbKysrW1tbi4uLq6ur29vYCu0YixzYOw14G0
1oaz14e114K124O03YWz2Ie12oW13Im10o621Ii22oi23Iy32oq52Y252Y+73ZS51Ze81JC625G7
3JG825K83Je72pW93Zq92Zi/35G+4aC90qG+15bA3ZnA3Z7A2pjA4Z/E4qLA2KDF3qTA2qTE3avF
36zG3rLM3aPF4qfJ5KzJ4LPL5LLM5LTO4rbN5bLR6LTR6LXQ6r3T5L3V6cLCwsTExMbGxsvLy8/P
z9HR0dXV1dbW1tjY2Nra2tzc3N7e3sDW5sHV6cTY6MnZ79De7dTg6dTh69Xi7dbj7tni793m7tXj
8Nbk9tjl9N3m9N/p9eHh4eTk5Obm5ujo6Orq6u3t7e7u7uDp8efs8uXs+Ozv8+3z9vDw8PLy8vL0
9/b29vb5+/f6+/j4+Pn6+/r6+vr6/Pn8/fr8/Pv9/vz8/P7+/gAAACH5BAMAAP8ALAAAAAB4ABgA
AAj/AP8JHEiwoMGDCBMqXMiwocOHECNKnEixosWLGDNqZCioo0dC0Q7Sy2btlitisrjpK4io4yF/
yjzKRIZPIDSZOAUVmubxGUF88Aj2K+TxnKKOhfoJdOSxXEF1OXHCi5fnTx5oBgFo3QogwAalAv1V
yyUqFCtVZ2DZceOOIAKtB/pp4Mo1waN/gOjSJXBugFYJBBflIYhsq4F5DLQSmCcwwVZlBZvppQtt
D6M8gUBknQxA879+kXixwtauXbhheFph6dSmnsC3AOLO5TygWV7OAAj8u6A1QEiBEg4PnA2gw7/E
uRn3M7C1WWTcWqHlScahkJ7NkwnE80dqFiVw/Pz5/xMn7MsZLzUsvXoNVy50C7c56y6s1YPNAAAC
CYxXoLdP5IsJtMBWjDwHHTSJ/AENIHsYJMCDD+K31SPymEFLKNeM880xxXxCxhxoUKFJDNv8A5ts
W0EowFYFBFLAizDGmMA//iAnXAdaLaCUIVtFIBCAjP2Do1YNBCnQMwgkqeSSCEjzzyJ/BFJTQfNU
WSU6/Wk1yChjlJKJLcfEgsoaY0ARigxjgKEFJPec6J5WzFQJDwS9xdPQH1sR4k8DWzXijwRbHfKj
YkFO45dWFoCVUTqMMgrNoQD08ckPsaixBRxPKFEDEbEMAYYTSGQRxzpuEueTQBlshc5A6pjj6pQD
wf9DgFYP+MPHVhKQs2Js9gya3EB7cMWBPwL1A8+xyCYLD7EKQSfEF1uMEcsXTiThQhmszBCGC7G0
QAUT1JS61an/pKrVqsBttYxBxDGjzqxd8abVBwMBOZA/xHUmUDQB9OvvvwGYsxBuCNRSxidOwFCH
J5dMgcYJUKjQCwlahDHEL+JqRa65AKD7D6BarVsQM1tpgK9eAjjpa4D3esBVgdFAB4DAzXImiDY5
vCFHESko4cMKSJwAxhgzFLFDHEUYkzEAG6s6EMgAiFzQA4rBIxldExBkr1AcJzBPzNDRnFCKBpTd
gCD/cKKKDFuYQoQVNhhBBSY9TBHCFVW4UMkuSzf/fe7T6h4kyFZ/+BMBXYpoTahB8yiwlSFgdzXA
5JQPIDZCW1FgkDVxgGKCFCywEUQaKNitRA5UXHGFHN30PRDHHkMtNUHzMAcAA/4gwhUCsB63uEF+
bMVB5BVMtFXWBfljBhhgbCFCEyI4EcIRL4ChRgh36LBJPq6j6nS6ISPkslY0wQbAYIr/ahCeWg2f
ufFaIV8QNpeMMAkVlSyRiRNb0DFCFlu4wSlWYaL2mOp13/tY4A7CL63cRQ9aEYBT0seyfsQjHedg
xAG24ofITaBRIGTW2OJ3EH7o4gtfCIETRBAFEYRgC06YAw3CkIqVdK9cCZRdQgCVAKWYwy/FK4i9
3TYQIboE4BmR6wrABBCUmgFAfgXZRxfs4ARPPCEOZJjCHVxABFAA4R3sic2bmIbAv4EvaglJBACu
IxAMAKARBrFXvrhiAX8kEWVNHOETE+IPbzyBCD8oQRZwwIVOyAAXrgkjijRWxo4BLnwIwUcCJvgP
ZShAUfVa3Bz/EpQ70oWJC2mAKDmwEHYAIxhikAQPeOCLdRTEAhGIQKL0IMoGTGMgIBClA9QxkA3U
0hkKgcy9HHEQDcRyAr0ChAWWucwNMIJZ5KilNGvpADtt5JrYzKY2t8nNbnrzm+B8SEAAADs="

  return [image create photo -format GIF -data $logoData]
}

set cons [pickCons]
makeWindow
tkwait window .

#
# DISCLAIMER:
# TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, POINTWISE DISCLAIMS
# ALL WARRANTIES, EITHER EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED
# TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE, WITH REGARD TO THIS SCRIPT.  TO THE MAXIMUM EXTENT PERMITTED 
# BY APPLICABLE LAW, IN NO EVENT SHALL POINTWISE BE LIABLE TO ANY PARTY 
# FOR ANY SPECIAL, INCIDENTAL, INDIRECT, OR CONSEQUENTIAL DAMAGES 
# WHATSOEVER (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF 
# BUSINESS INFORMATION, OR ANY OTHER PECUNIARY LOSS) ARISING OUT OF THE 
# USE OF OR INABILITY TO USE THIS SCRIPT EVEN IF POINTWISE HAS BEEN 
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGES AND REGARDLESS OF THE 
# FAULT OR NEGLIGENCE OF POINTWISE.
#

