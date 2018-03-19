clear
rm nodes
rm edges
echo $1
 grep -i author $1 | sort | uniq | cut -f 2 -d"=" | sed 's/[{}]//g' |
 awk '
 function cleanAuthor(a)
    {
        a = tolower(a)
        b = gensub(/[,\"]/, "", "g", a)

        n = split(b, ar, " ")
        if( ( ar[1] == "van" || ar[1] == "de")  && n > 2){

            beg = ar[1]
            if(ar[2] == "de"){
                zw = ar[3]}else{
                zw = ar[2]}
        }else{
            beg = ar[1]
            zw = substr(ar[2],1,1)
        }

        return beg "-" zw
    }
 BEGIN{FS="and"
    i = 0;
    authoren["0"] = 0
    #edges["0"]["0"]    = 0
    print "edgedef>node1 VARCHAR,node2 VARCHAR, weight DOUBLE" > "edges"
 }{for ( i = 1; i <= NF; i++ )
                {
                    # these authors are in a paper, remember that:
                    author1 = cleanAuthor($i)
                    authoren[author1]++
                        for ( j = i+1; j <= NF; j++ )
                        {
                                if(j != i){
                                    author2 = cleanAuthor($j)

                                    # we remove to shot author names,
                                    #there is not enough entropy in the world
                                    if(length(author1) > 5 && length(author2) > 5){
                                        #print author1"," author2
                                        # counting the edges and weight
                                        edges[author1][author2]++
                                    }
                                }
                        }
                }}
                END{
                    # printing the output
                    print "nodedef>name VARCHAR,label VARCHAR,width DOUBLE" > "nodes"
                    for(author in authoren){
                        if(authoren[author] > 5){
                            print author","author"," authoren[author] >> "nodes"
                           if(author in edges){

                                for(n in edges[author]){
                                    if(authoren[n] > 5 && author != n){
                                        print author","n","edges[author][n] >> "edges"
                                    }
                                }
                            }
                        }
                    }
                }'




cat edges >> nodes
mv nodes "$1.gdf"
head "$1.gdf"
