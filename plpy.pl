#!/usr/bin/perl -w

# written by Zhimai Wang
# for COMP9041, Assignment 1
# September, 2016

@perl = <>;
# print @perl, "\n";
# print "-----\n";
@python = ();
@python_head = ();

$space = 0;

# @while_python = ();
# @if_python = ();
# %operators = ("eq"=>"==",
#               "ne"=>"!=");
@condition = ();
$type_cast = "";





sub translate_statement {
    # $perl = shift @perl;
    # print "$perl[0]";
    #Subset 0: simple print & strings
    if ($perl[0] =~ /.*<STDIN>/){ #add import sys

        # push @python_head, "import sys\n";
        $import{sys} = 1;
        translate_import();
    }

    if ($perl[0] =~ /.*ARGV\b/){ #add import sys
        if (!defined($import{sys})) {
            $import{sys} = 1;
            # translate_import();
        }
        translate_import();
        # print "$import{sys}\n";
        # translate_import();
    }

    if ($perl[0] =~ /.*<>/) { #add import fileinput
        # push @python_head, "import fileinput\n";
        $import{fileinput} = 1 if (!defined($import{fileinput}));
        # print "$import{fileinput}\n";
        translate_import();
    }

    if ($perl[0] =~ /s\/.*\/.*\/g/) { #add import re
        # push @python_head, "import re\n";
        $import{re} = 1 if (!defined($import{re}));
        translate_import();
    }

   

    if ($perl[0] =~ /^#!/){
        # print "elsif: $perl[0]\n";
        $perl = shift @perl;
        push @python_head, "#!/usr/local/bin/python3.5 -u\n";
        # return "#!/usr/local/bin/python3.5 -u\n";
        return "";
    } elsif ($perl[0] =~ /^\s*#/ || $perl[0] =~ /^\s*$/){ #translate comments
        # print "elsif: $perl[0]\n";
        $perl = shift @perl;
        # print "empty $perl end\n";
        return $perl;
    } elsif ($perl[0] =~ /^\s*print/){ #translate print
        # @print_python = ();
        # print "print yes: $perl[0]\n";
        # print "elsif: $perl[0]\n";
        return translate_print();
    } elsif ($perl[0] =~ /^\s*for.*/){
        # print "elsif: $perl[0]\n";
        return translate_for();
    } elsif ($perl[0] =~ /^\s*\%/) {
        return translate_hash();
    } elsif ($perl[0] =~ /\@/) { #translate array
        return translate_array();
    
    } elsif ($perl[0] =~ /\$\#/) { #translate array
        return translate_array();
    } elsif ($perl[0] =~ /^\s*\$/){ #translate variable
        return translate_variable();
    } elsif ($perl[0] =~ /^\s*\bif\b/){ #translate if statement
        # print "if1: $perl[0]\n";
        return translate_if();
    } elsif ($perl[0] =~ /\s*}\s*els/) { #translate else statement
        # print "els: $perl[0]\n";
        return translate_if();
    } elsif ($perl[0] =~ /^\s*while\b/){ #translate while statement
        # print "elsif: $perl[0]\n";
        return translate_while();
    
    } elsif ($perl[0] =~ /^\s*chomp\b/){ #translate chomp
        # print "chomp\n";
        # print "elsif: $perl[0]\n";
        return translate_chomp();
    } elsif ($perl[0] =~ /^\s*last\b/){ #translate last
        # print "break\n";
        # print "elsif: $perl[0]\n";
        return translate_last();
    } elsif ($perl[0] =~ /^\s*next\b/) { #translate next
        return translate_next();
    } elsif ($perl[0] =~ /delete/){
        return translate_delete();
    } elsif ($perl[0] =~ /exit/){
        return translate_import();
    } else {
        # print "elsif: $perl[0]\n";
        $perl = shift @perl;
        return "#$perl\n";
    }
}




sub translate_hash {
    $perl = shift @perl;
    if ($perl =~ /^\s*\%(.*)\s*=\s*\((.*)\)/){ #%hash=(key1, value1, key2, value2...)
        $dic = $1;
        $content = $2;
        if ($content =~ /=>/){
            $content =~ s/=>/:/g;
            # print "$content\n";
            $perl = "$dic = \{$content\}";
        }else {
            @con = split(',', $content);
            $new = "";
            $num =($#con - 1) / 2;
            for $i (0..$num){
                $i *= 2;
                $new .= "$con[$i]:$con[$i+1],";
                # $i += 2;
            }
          
            $new =~ s/,$//g;
            
            $perl = "$dic = \{$new\}";
        }
    } 

    if ($perl =~ /keys/) { # save keys as array
        if ($perl =~ /^\s*\@(.*)\s*=\s*keys\s*\%(\w*)[\s;]*$/) {
            $arr = $1;
            $dic = $2;
            # print "arr:$arr, dic:$dic\n";
            $perl = "$arr = list\($dic\.keys\(\)\)";
        }
    }

    if ($perl =~ /values/) {
        if ($perl =~ /^\s*\@(.*)\s*=\s*values\s*\%(\w*)[\s;]*$/){
            $arr = $1;
            $dic = $2;
            $perl = "$arr = list\($dic\.values\(\)\)";
        }
    }
    return "$perl\n";
}


sub translate_array {
    $perl = shift @perl;


    if ($perl =~ /\s*\@.*\s*=\s*\(.*\)/){ # @array = ()
        $perl =~ tr/\(\)/\[\]/;
    }

    if ($perl =~ /^\s*push\s*\(\s*\@(.*)\s*,\s*(.*)\s*\)/){ #push with bracket
        $arr = $1;
        $variable = $2;
        # print "arr:$arr, var: $variable\n";
        $perl = "$arr\.append\($variable\)";
    } elsif ($perl =~ /^\s*push\s*\@(.*)\s*,\s*(.*)/){ #push without bracket
        $arr = $1;
        $variable = $2;
        # print "arr:$arr, var: $variable\n";
        $perl = "$arr\.append\($variable\)";
    }


    if ($perl =~ /\s*unshift\s*\(\s*\@(.*)\s*,\s*(.*)\s*\)/){ #unshift
        $arr = $1;
        $variable = $2;
        $perl = "$arr\.insert\(0,$variable\)";
    } elsif ($perl =~ /\s*unshift\s*\s*\@(.*)\s*,\s*(.*)\s*/){
        $arr = $1;
        $variable = $2;
        $perl = "$arr\.insert\(0,$variable\)";
    }

    if ($perl =~ /\s*pop\s*\(\@(.*)\)/) { #pop
        $arr = $1;
        $perl = "$arr\.pop\(\)";
    } elsif ($perl =~ /\s*pop\s*\@(.*)/) {
        $arr = $1;
        $perl = "$arr\.pop\(\)";
    }

    if ($perl =~ /\s*shift\s*\(\@(.*)\)/) { #shift
        $arr = $1;
        $perl = "$arr\.pop\(0\)";
    } elsif ($perl =~ /\s*shift\s*\@(.*)/) {
        $arr = $1;
        $perl = "$arr\.pop\(0\)";
    }



    # $perl =~ tr/\(\)/\[\]/;
    if ($perl =~ /\s*\$(\w*)\s*=\s*\@(\w*)/) { # $a = @array
        $variable = $1;
        $arr = $2;
        $perl = "$variable = len($arr)";
        # print "1";
    }

    if ($perl =~ /\s*\$(\w*)\s*=\s*scalar\s*\@(\w*)/) { # $a = scalar @array
        # print "33333\n";
        $variable = $1;
        $arr = $2;
        $perl = "$variable = len($arr)";
        # print "2";

        # print "$variable\n";
    }

    if ($perl =~ /\s*\$(\w*)\s*=\s*\$\#(\w*)/) { # $a = $#array
        $variable = $1;
        $arr = $2;
        $perl = "$variable = len($arr) - 1";
        # print "3";
    }


    if ($perl =~ /^\s*\$(.*)\s*=\s*join\s*\((.*)\s*,\s*(.*)\)/) { #join function
        $str = $1;
        # chomp $str;
        $str =~ s/\s*//g;;
        $delimeter = $2;
        $delimeter =~ s/\s*//g;
        # chomp $delimeter;
        $arr = $3;
        $arr =~ s/\s*//g;
        
        $perl = "$str = $delimeter.join($arr)";
    }

    if ($perl =~ /\s*\@(.*)\s*=\s*sort\s*/){
        $arr = $1;
        $arr =~ s/\s*//g;
        $perl = "$arr.sort()";
    }




    if ($perl =~ /\s*\@(.*)\s*=\s*split\s*\((.*)\s*,\s*\$(.*)\)/){
        $arr = $1;
        $delimeter = $2;
        $str = $3;
        # print "$arr, $delimeter, $str\n";
        $perl = "$arr= $str\.split\($delimeter\)";
    } elsif ($perl =~ /\s*\@(.*)\s*=\s*split\s*(.*)\s*,\s*\$(.*)/) {
        $arr = $1;
        $delimeter = $2;
        $str = $3;
        # print "$arr, $delimeter, $str\n";
        $perl = "$arr= $str\.split\($delimeter\)";
    }

    if ($perl =~ /keys/) { # save keys as array
        if ($perl =~ /^\s*\@(.*)\s*=\s*keys\s*\%(\w*)[\s;]*$/) {
            $arr = $1;
            $dic = $2;
            # print "arr:$arr, dic:$dic\n";
            $perl = "$arr = list\($dic\.keys\(\)\)";
        }
    }

    if ($perl =~ /values/) {
        if ($perl =~ /^\s*\@(.*)\s*=\s*values\s*\%(\w*)[\s;]*$/){
            $arr = $1;
            $dic = $2;
            $perl = "$arr = list\($dic\.values\(\)\)";
        }
    }

    $perl =~ s/\@//g;
    $perl =~ s/\$//g;
    $perl =~ s/;//g;

    
    # print "array: $perl\n";

    if ($perl =~ /\s*(.*)\s*=\s*\[(\d*)\.\.(\d*)\]/) {
        # print "11111\n";
        $variable = $1;
        $start = $2;
        $end = $3 + 1;
        $perl = "$variable = list(range($start, $end))";
    
    } elsif ($perl =~ /\s*(.*)\s*=\s*\[([a-z]*)\.\.([a-z]*)\]/i) {
        # print "22222\n";
        $variable = $1;
        $start = $2;
        $end = $3;
        $perl = "$variable = list(map(chr, range(ord(\'$start\'), ord(\'$end\') + 1)))";
        # print "5";
    }

    return "$perl\n";
}






#need nodify
sub translate_print {
    $perl = shift @perl;
    # print "$perl\n";
    my @print_python = ();
    

    if ($perl =~ /\{.*\}/){
        # print "print hash\n";
        if ($perl =~ /^\s*print\s*"(.*)\s*=\s*(.*)\s*\\n"[\s;]*$/) { #print "\$h{k} = $h{k}"
            $left = $1;
            $right = $2;
            # print "left:$left, right:$right\n";
            $left =~ s/\\*\$*//g;
            # print "$perl\n";
            $left =~ tr/\{\}/\[\]/;
            $left =~ s/\'//g;
            $left =~ s/\[/\[\'/g;
            $left =~ s/\]/\'\]/g;

            $right =~ s/\\*\$*//g;
            $right =~ tr/\{\}/\[\]/;
            $right=~ s/\'//g;
            $right =~ s/\[/\[\'/g;
            $right =~ s/\]/\'\]/g;
            # @p = split('=', $perl);
            # print "@p\n";
            return "print(\"$left=\", $right)\n";
        } elsif ($perl =~ /^\s*print\s*"(.*)\\n"[\s;]*$/) { #print single hash value
            
            $perl = $1;
            # print "$perl\n";
            if ($perl =~ /\{\$/) {
                $perl =~ s/\\*\$*//g;;
                $perl =~ tr/\{\}/\[\]/;
            }else {
                $perl =~ s/\\*\$*//g;;
                $perl =~ tr/\{\}/\[\]/;
                $perl =~ s/\'//g;
                $perl =~ s/\[/\[\'/g;
                $perl =~ s/\]/\'\]/g;
            }
            

            return "print($perl)\n";

        }
        
    }elsif ($perl =~ /^\s*print\s*"([^"]*)\\n"[\s;]*$/) { #with quote
        $perl = $1;
        # print "2:$perl";
        if ($perl !~ /[\$\@]/) { #only print string
            return "print(\"$perl\")\n";
        } else {

            my @print_temp = ();
            @print_temp = split(/\s+/, $perl);
            foreach $p (@print_temp){
            if ($p =~ /\$ARGV\[(.*)\]/) { #ARGV
                $index = $1;
                $index =~ s/\$//g;
                push @print_python, "sys.argv[$index + 1],";

            }elsif($p =~ /^\s*\$/){ #start with $
                $p =~ s/\$//g;
                $p =~ s/\.//g;
                push @print_python, "$p,";
            }elsif($p =~ /^\s*\@/){ #start with @
                $p =~ s/\@/\*/g;
                push @print_python, "$p,";
            }elsif($p =~ /\\\@/){ #\@
                $p =~ s/\\//g;
                push @print_python, "\"$p\",";
            }elsif($p =~ /\\\$/){ #\$
                $p =~ s/\\//g;

                # print "$p\n";
                if ($p =~ /^\s*\$(.*)\[\$(.*)\]/){
                    $arr = $1;
                    $index = $2;
                    $p = "$arr\[$index\]";
                }
                push @print_python, "\"$p\",";
            }else{ #string
                push @print_python, "\"$p\",";
            }
        }
            $print_python[$#print_python] =~ s/,//g;
            return "print(@print_python)\n";
            # return "@print_temp\n";
        }
        
    } elsif ($perl =~ /printf/) {
        # print "printf\n";
        $perl =~ /^\s*printf\s*"([^"]*)"\s*,\s*(.*)/;
        $sentence = $1;
        $var = $2;
        $sentence =~ s/\\n//g;
        $sentence =~ s/\\//g;
        $var =~ s/;//g;
        # print "sen:$sentence, var:$var\n";
        $perl = "print\(\"$sentence\" \% \($var\)\)";

        return "$perl\n";
    }else {
        $perl =~ s/,\s*"\\n"//g;
        if ($perl =~ /^\s*print\s*(\$*.*["]+.*\$*.*);$/) { #quote and no quote
            $perl = $1;
            my @print_temp = ();
            @print_temp = split(/,\s*/, $perl);
            foreach $p (@print_temp){
                $p =~ s/\\n//g;
                $p =~ s/\$//g;
                push @print_python, "$p,";
            }
            $print_python[$#print_python] =~ s/,//g;
            return "print(@print_python)\n";
        } elsif ($perl =~ /^\s*print\s*(.*\$.*).*;$/) {
            $perl = $1;
            $perl =~ s/\$//g;
            $perl =~ s/\@//g;
            return "print($perl)\n";
        } elsif ($perl =~ /^\s*print\s*(.*join.*).*/) {
            # print "bug: $perl\n";
            $perl = $1;
            return "print($perl)\n";
        }
        
    }
}

sub translate_variable {
    $perl = shift @perl;
    
    $perl =~ /\s*(.*)/;

    $perl = $1;
    if ($perl =~ /\+\+/) { #translate i++ to i += 1
        $perl =~ s/\+\+/ += 1/g;
    }

    if ($perl =~ /\-\-/) { #translate i-- to i -= 1
        $perl =~ s/\-\-/ -= 1/g;
    }

    if ($perl =~ /\{.*\}/){ #$hash{key} = value
        # print "$perl\n";
        $perl =~ /^\s*\$(.*)\{.*/;
        $hash = $1;
        # print "h:$hash\n";
        $definiHash{$hash} = 1;
        $perl =~ tr/\{\}/\[\]/;


    }

    if ($perl =~ /^\s*\$(.*)\s*=~\s*s\/(.*)\/(.*)\//){
        # print "yes\n";
        $import{re} = 1;
        $str = $1;
        # $str =~ s/\s*//g;
        $pattern = $2;
        $replacement = $3;
        $perl = "$str = re\.sub\(\'$pattern\', \'$replacement\', $str, 1\)";
    }

    if ($perl =~ /\$(.*)\s*=~\s*[^s]\/(.*)\//){ # $perl =~ //
        $import{re} = 1;
        $str = $1;
        $pattern = $2;
        $str =~ s/\s*//g;
        $re = $str;
        $perl = "$str = re\.search\(\'$pattern\', $str\)\nif $str:";
    }

    if ($perl =~ /^\s*\$(.*)\s*=\s*\$(\d[^A-Za-z]*)/){ # $p = $1
        $import{re} = 1;
        $var = $1;
        $group_id = $2;
        # print "var:$var, group:$group_id\n";
        $var =~ s/\s*//g;
        # $perl = "$var = $re\.group\($group_id\)";
        $perl = "    " x ($space + 1)."$var = $re\.group\($group_id\)";
        # $perl = "    " x $space, $perl;

    }


    $perl =~ s/[\$;]//g;

    return "$perl\n";


}

sub translate_if {
    
    $perl = shift @perl;
    # print "bug: $perl\n";

    if ($perl =~ /^\s*\bif\b\s*\((.*)\)[\s{]*$/){
        # print "if:$perl\n";
        $perl = $1;
        # print "$perl\n";

        if ($perl =~ /[!=<>%]/) {
            if($type_cast) {
                $type_cast =~ s/\$//g;
                push @python, "$type_cast = float($type_cast)\n";
                $type_cast = "";
            }
        }

        if ($perl =~ /=~/){ 
            # print "has\n";
            $import{re} = 1;
            # print "$perl\n";
            if ($perl =~ /\$(.*)\s*=~\s*[^s]\/(.*)\//){ #match
                $str = $1;
                $pattern = $2;
                $re = $str;
                # print "str:$str, pattern:$pattern\n";
                $perl = "re\.search\(\'$pattern\', $str\)";      
            } 
        
                  
        } elsif ($perl =~ /!~/){ 
            $import{re} = 1;
            # print "$perl\n";
            if ($perl =~ /\$(.*)\s*!~\s*[^s]\/(.*)\//){ # not match
                $str = $1;
                $pattern = $2;
                # print "str:$str, pattern:$pattern\n";
                $perl = "not re\.search\(\'$pattern\', $str\)";
            }
              
        }
        $perl =~ s/!/not /g;
        $perl =~ s/\$//g;
        $perl =~ s/\beq\b/==/g;
        $perl =~ s/\bne\b/!=/g;
        $perl =~ s/\ble\b/<=/g;
        $perl =~ s/\bge\b/>=/g;
        $perl =~ s/\blt\b/</g;
        $perl =~ s/\bgt\b/>/g;
        $perl =~ s/\|\|/or/g;
        $perl =~ s/\&\&/and/g;
        
        
        push @condition, ("    " x $space, "if $perl:\n");
        $space++;
    } elsif ($perl =~ /^\s*}\s*else\s*{/) { #translate } else {
       
        return "else:\n";
    } elsif ($perl =~ /\s*}\s*elsif\b\s*\((.*)\)\s*{/) { #translate } elsif {
        # print "elsif: $perl\n";
        $perl = $1;

        if ($perl =~ /[!=<>%]/) {
            if($type_cast) {
                
                $type_cast =~ s/\$//g;
                push @python, "$type_cast = float($type_cast)\n";
                $type_cast = "";
            }
        }

        if ($perl =~ /=~/){ 
            # print "has\n";
            $import{re} = 1;
            # print "$perl\n";
            if ($perl =~ /\$(.*)\s*=~\s*[^s]\/(.*)\//){ #match
                $str = $1;
                $pattern = $2;
                $re = $str;
                # print "str:$str, pattern:$pattern\n";
                $perl = "re\.search\(\'$pattern\', $str\)";      
            } 
           
        } elsif ($perl =~ /!~/){ 
            $import{re} = 1;
            # print "$perl\n";
            if ($perl =~ /\$(.*)\s*!~\s*[^s]\/(.*)\//){ # not match
                $str = $1;
                $pattern = $2;
                # print "str:$str, pattern:$pattern\n";
                $perl = "not re\.search\(\'$pattern\', $str\)";
            }
              
        }

        $perl =~ s/!/not /g;
        $perl =~ s/\$//g;
        $perl =~ s/\beq\b/==/g;
        $perl =~ s/\bne\b/!=/g;
        $perl =~ s/\ble\b/<=/g;
        $perl =~ s/\bge\b/>=/g;
        $perl =~ s/\blt\b/</g;
        $perl =~ s/\bgt\b/>/g;
        $perl =~ s/\|\|/or/g;
        $perl =~ s/\&\&/and/g;
        # $perl =~ s/!/not /g;
       


        return "elif $perl:\n";
    }
    
    while((@perl && $perl[0] !~ /^\s*}/) || (@perl && $perl[0] =~ /^\s*}\s*els/)){
        # print "while: $perl[0]\n";
        # if ($perl[0] !~ /else/) {
        $temp = translate_statement();
        # $temp =~ /\s*(.*)/;
        if ($temp && $temp !~ /(els)|(elif)/) {
            push @condition, ("    " x $space, $temp);
        } elsif ($temp && $temp =~ /els/) {
            push @condition, ("    " x ($space - 1), $temp);
        } elsif ($temp && $temp =~ /elif/) {
            push @condition, ("    " x ($space - 1), $temp);
        }
       
        
    }
    $perl = shift(@perl) || "";
    $perl =~ /^\s*}\b/;
    $space--;
   
    if (!$space){
        @result = @condition;
        @condition = ();
        return @result;
    }
    
}


sub translate_while {
    
    $perl = shift @perl;
    if($perl =~ /^\s*while\s*\((.*)\)[\s{]*$/){
        $perl = $1;
        $perl =~ s/\$//g;
        $perl =~ s/\beq\b/==/g;
        $perl =~ s/\bne\b/!=/g;
        $perl =~ s/\ble\b/<=/g;
        $perl =~ s/\bge\b/>=/g;
        $perl =~ s/\blt\b/</g;
        $perl =~ s/\bgt\b/>/g;

       
        push @condition, ("    " x $space,"while $perl:\n");
        $space++;
    }
    
    while(@perl && $perl[0] !~ /^\s*}/){
        # print "$space: $perl[0]\n";
        $temp = translate_statement();
        # $temp =~ /\s*(.*)/;
        # chomp $temp;
        push @condition, ("    " x $space, $temp) if $temp;
    }
    $perl = shift(@perl) || "";
    $perl =~ /^\s*}\b/;
    $space--;
    if(!$space){
        @result = @condition;
        @condition = ();
        return @result;
    }
    
}


sub translate_for {
    # @for_python = ();
    $perl = shift @perl;
    # print "for: $perl\n";
    
    if ($perl =~ /.*argv\[1:\].*/) { #for arg in sys.argv[1:]
        # print "for: $perl\n";
        # print "yyyy\n";
        $perl =~ /^\s*for\w*\s*\$(\w*)\s(.*)[\s{]*$/;
        $arg = $1;
        # print "arg: $arg\n";
        $args = $2;
        # print "args: $args\n";
        # push @for_python, "for $arg in $args:\n";
        push @condition, ("    " x $space, "for $arg in $args:\n");
        $space++;
    } elsif ($perl =~ /^\s*for\w*\s*\s\$(\w*)\s*\(\s*keys\s*\%(\w*)\)[\s{]*$/) { #for k in h.keys()
        $key = $1;
        $dic = $2;
        # print "key:$key,, dic:$dic\n";
        push @condition, ("    " x $space, "for $key in $dic\.keys\(\):\n");
        $space++;

    } elsif ($perl =~ /^\s*for\w*\s*\s\$(\w*)\s*\(\s*sort\s*keys\s*\%(\w*)\)[\s{]*$/) { #for k in sorted(h.keys())
        $key = $1;
        $dic = $2;
        # print "key:$key,, dic:$dic\n";
        push @condition, ("    " x $space, "for $key in sorted\($dic\.keys\(\)\):\n");
        $space++;
    }elsif ($perl =~ /^\s*for\w*\s*\$(\w*)\s*\((\d*)..(\d*)\)[\s{]*$/) { #for i in range(0..5)
        # print "yes\n";
        $arg = $1;
        $start = $2;
        $end = $3 + 1;
        # push @for_python, "for $arg in range($start, $end):\n";
        push @condition, ("    " x $space, "for $arg in range($start, $end):\n");
        $space++;
    } elsif ($perl =~ /^\s*for\w*\s*\$(\w*)\s*\(\@(.*)\)[\s{]*$/) { #for arg in sys.argv[1:]
        # print "yes\n";
        $arg = $1;
        $args = $2;
        # push @for_python, "for $arg in $args:\n";
        push @condition, ("    " x $space, "for $arg in $args:\n");
        $space++;
    } elsif ($perl =~ /fileinput/) { #for perl in fileinput.input()
        push @condition, ("    " x $space, "$perl\n");
        $space++;
    } elsif ($perl =~ /range\(len\(sys.argv\) - 1\)/) { #for i in range(len(sys.argv) - 1)
        # print "perl: $perl\n";
        push @condition, ("    " x $space, "$perl\n");
        $space++;
    } elsif ($perl =~ /sys\.stdin/) {
        push @condition, ("    " x $space, "$perl\n");
        $space++;
    }
    # print "perl0:$perl[0]\n";
    while(@perl && $perl[0] !~ /^\s*}/) {
        $temp = translate_statement();
        # print "temp: $temp\n";
        # print "perls: @perl\n";
        push @condition, ("    " x $space, $temp) if $temp;
        # push @for_python, ("    " x $space,translate_statement());
    }
    $perl = shift(@perl) || "";
    # print "end: $perl\n";
    $perl =~ /^\s*}\b/;

    $space--;
    if (!$space) {
        @result = @condition;
        @condition = ();
        return @result;
    }
   
}


sub translate_import {
    $perl = shift @perl;
    # print "perl: $perl\n";
    # print "yyyyy\n";
    if($perl =~ /.*\<STDIN\>.*/){ #<STDIN>
        if ($perl =~ /\s*while\s*\(\s*\$(\w*).*\)/) {
            $perl = $1;
            unshift @perl, "for $perl in sys.stdin:";
        } elsif ($perl =~ /\s*(.*\s*=\s*\<STDIN\>.*)/) {
            $perl = $1;
            $perl =~ s/\<STDIN\>/sys.stdin.readline()/g;
            $perl =~ /\s*(.*)\s*=/;
            $type_cast = $1;
            unshift @perl, "$perl\n";
        }
        
    } elsif ($perl =~ /ARGV/){ # @ARGV
        if ($perl =~ /(\s*.*)(join\(.*\))/){ #join function
            $perl = $1;
            $join = $2;
            my ($symbol, $args) = $join =~ /\((.*)\s*,\s*(.*)\)/;
            $perl = $perl.$symbol.".join(sys.argv[1:])";
            # print "1: $perl\n";
            unshift @perl, "$perl\n";
        } elsif ($perl =~ /(.*)\((\@ARGV)\)/) { #other
            $perl = $1;
            # print "1: $perl\n";
            $perl .= "sys.argv[1:]";
            
            unshift @perl, "$perl\n";
        } elsif ($perl =~ /^\s*foreach\s*\$(\w*)\s*\((.*)\.\.(.*)\)[\s{]*$/) {
            # print "1:$1, 2:$2, 3:$3,\n";
            $perl = $1;
            $start = $2;
            $end = $3;
            if ($start == 0) {
                # print "yes\n";
                if ($end eq "\$#ARGV") {
                    # print "yyyyyes\n";
                    # print "for $perl in range(len(sys.argv) - 1)\n";
                    unshift @perl, "for $perl in range(len(sys.argv) - 1):";
                    # print "import: @perl\n";
                }
            }
        }
    } elsif ($perl =~ /\(([^\s]*)\s*=\s*<>\)/) { #<>
        $perl = $1;
        $perl =~ s/\$//g;

        # print "$perl\n";
        unshift @perl, "for $perl in fileinput.input():";
    } elsif ($perl =~ /\s*([^\s]*)\s*=~\s*s\/(.*)\/(.*)\/g/) {
        $perl = $1;
        # $perl =~ s/\$//g;
        $pattern = $2;
        $replacement = $3;
        # print "perl: $perl; pattern: $pattern; replacement: $replacement\n";
        unshift @perl, "$perl = re.sub(r\'$pattern\', \'$replacement\', $perl)\n";
    } elsif ($perl =~ /exit/) {
        $import{sys} = 1;
        $perl = "sys\.exit\(\)";
        return "$perl\n";


    }
}


sub translate_chomp {
    $perl = shift @perl;
    $perl =~ /^\s*chomp\s*(.*);/;
    $perl = $1;
    $perl =~ s/\$//g;
    $perl .= " = $perl.rstrip()";
    return "$perl\n";
}



sub translate_last {
    $perl = shift @perl;
    $perl = "break";
    return "$perl\n";
}

sub translate_next {
    $perl = shift @perl;
    $perl = "continue";
    return "$perl\n";
}

sub translate_delete {
    $perl = shift @perl;
    if ($perl =~ /\{.*\}/){
        if ($perl =~ /^\s*delete\s*\$(.*)\{(.*)\}[\s;]*$/){
            $dic = $1;
            $key = $2;
            $perl = "del $dic\[$key\]";
        }
    }
    return "$perl\n";
}

while(@perl){
    push @python, translate_statement();
}
print @python_head;
if (%import) {
    print "import ";
    print join(', ', sort keys %import), "\n";
}
if(%definiHash) {
    for $k (keys %definiHash){
        print "$k = {}\n";
    }
}
print @python;

