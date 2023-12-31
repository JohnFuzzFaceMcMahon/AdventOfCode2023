BEGIN {
    # Are we in a map? 
    InAMap=0
    # Map number?
    MapNumber=0

    M["seed-to-soil"]=1
    M["soil-to-fertilizer"]=2
    M["fertilizer-to-water"]=3
    M["water-to-light"]=4
    M["light-to-temperature"]=5
    M["temperature-to-humidity"]=6
    M["humidity-to-location"]=7

}

# Process the seed input
/^seeds:/ {
    for (i=2;i<=NF;i++) {
        SEEDLIST[$i]=1
    }
}

# End Of A Map
/^$/ {
    # print "MAP END"
    InAMap=0
    MapNumber=0
}

# Map 
/^[a-z-]* map:/ {
    # print "MAP '" $1 "' '" M[$1] "'"
    # InAMap is used as the row inside the map
    InAMap=1
    MapNumber=M[$1]
}

# Main Input Loop
{
    # print NR " '" $0 "'";
    if ( InAMap>0 ) {
        if ( index($0,"map:")==0 ) {
            # InAMap is used as the row inside the map
            MAP[ MapNumber "|" InAMap "|DRS" ]=$1
            MAP[ MapNumber "|" InAMap "|SRS" ]=$2
            MAP[ MapNumber "|" InAMap "|RL" ]=$3
            MAP[ MapNumber "|ROWS" ]=InAMap
            InAMap++
        } else {
            # This is the header line, ignore it.
        }
    }
}

END {
    if (0) {
        printf("SEEDLIST: ")
        for (i in SEEDLIST) {
            printf("%s,",i)
        }
        print "EOL"
    }
    if (0) {
        for (i=1;i<=7;i++) {
            for (j=1;j<=MAP[ i "|ROWS" ]; j++) {
                print "MAP '" i "' ROW '" j "' DRS '" MAP[ i "|" j "|DRS" ] "' SRS '" MAP[ i "|" j "|SRS" ] "' RL '" MAP[ i "|" j "|RL" ] "'"
            }
        }
    }

    LowestLocation=9999999999
    for (i in SEEDLIST) {
        # print "SEED ",i
        Solution=i
        for (j=1;j<=7;j++) {
            Solution=ResolveMap(j,Solution)
            # print "MAP ",j," SOL ",Solution
        }
        print "SEED# '" i "' LOCATION# '" Solution "'"
        if ( LowestLocation>Solution) { 
            LowestLocation=Solution
            print "Lowest Location: " LowestLocation
        }
    }
    print "Lowest Location: " LowestLocation
}

function ResolveMap(RMMapNumber, RMSeed, RMReturnValue, RMLoop, RMSRSMin, RMSSRSMax   ) {
    # assume there is no map solution
    RMReturnValue=RMSeed
    for (RMLoop=1;RMLoop<=MAP[ RMMapNumber "|ROWS" ]; RMLoop++) {
        # Source Range
        RMSRSMin=MAP[ RMMapNumber "|" RMLoop  "|SRS" ]
        # Off by one error if you add SRS + RL
        RMSSRSMax=RMSRSMin+MAP[ RMMapNumber "|" RMLoop  "|RL" ]-1
        # Seed is in source range
        if (( RMSRSMin<=RMSeed) && ( RMSeed<=RMSSRSMax )) {
            RMReturnValue=(RMSeed-RMSRSMin)+MAP[ RMMapNumber "|" RMLoop  "|DRS" ]
            # Another potential gotcha is overlaps 
            # print MAP[ RMMapNumber "|" RMLoop  "|SRS" ] " " MAP[ RMMapNumber "|" RMLoop  "|RL" ] " MIN " RMSRSMin " MAX " RMSSRSMax " RMRV ", RMReturnValue
        }
    }
    return RMReturnValue 
}

