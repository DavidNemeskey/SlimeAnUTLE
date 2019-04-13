


human language technologies (HLT), 
interpreted regular tree grammars (IRTG), 
(hyperedge-replacement grammar, HRG) ,
string algebra (SA) lánc algebra, 
tagtree algebra (TTA) címkéző fa algebra, 
s-graph algebra (SGA) s-gráf algebra, 
syntax tree (ST) Szintaktikai Fa, 
dependency graph (DG)  függőségi gráf, 
universal dependency graph (UDG) univerzális függőség gráf, 
four language graph (4LG) 4nyelv gráf, 
derivation tree (DT) derivációs fa

Bevezetés

Manapság egyre több technológia jelenik meg, aminek alapja az NLP(Natural Language Processing). Ezek a technológiák nagy része nem lenne megvalósítható szemantikai elemzés nélkül. A szemantikai elemzés célja, hogy egy nyers szövegből, vagy beszédhangból előállítsa annak a szemantikai reprezentációját. Sok esetben ez a reprezentáció egy gráf. Ha ezt a gráf reprezentációt a szintaktika egy gráf formátumú reprezentációjából szeretnénk generálni, akkor az elemzés felfogható egy automatizált gráftranszformáció ként is. 
Bár szemantikai elemzésre számos Deep Learning-es megoldás létezik, ezek pontatlansága nagy igényt teremt egy analitikus mély szemantikai elemzési módszerre. A gráf transzformációs megközelítés ígéretes eredményeket mutatott fel, mint például a Stanford Parser, ami TREGEX-ek segítségével végzi el tiszta analitikus módon a transzformációkat.
Több formalizmus is létezik a transzformációk leírására, mint például a HRG (hyperedge-replacement grammar) vagy az IRTG(interpreted regular tree grammars). Jelenleg is egy ezekkel kapcsolatos kutatás folyik az AUT tanszéken, ami már számos publikációt is eredményezett, mint például … .
A kutatás során az ALTO(Algebraic Language Toolkit)-val dolgoztunk, ami a jelenlegi leghatékonyabb környezet IRTG-k futtatására. Ugyanakkor a kutatásnak állandó gátját jelenti, hogy az IRTG még egy fejletlen nyelvtan és nehezen átlátható; és az ALTO-ból is hiányoznak fontos funkcionalitások. A problémán sokat enyhítene, ha az IRTG szabályokat REGEX-ek segítségével is meglehetne hivatkozni.
Szakdogám keretében egy templatelésre alkalmas nyelvet fejlesztettem ki, ami a Slime fantázianévre hallgat. Segítségével az IRTG nyelvtanokat tömörebben és átláthatóbban lehet definiálni. Mivel az ALTO java-ban készül, a nyelv Kotlinban készül ANTLRv4 segítségével. Még nincs teljesen kifejlődve, de a feladathoz szükséges megoldásokat tartalmazza. Ilyen például a template definiálás, egymásba ágyazás, regexxel hivatkozás és sok egyéb. Teljes formájában egy univerzális bővítmény lesz, ami bármely nyelv vagy szöveg felett használható.


Szemantikai elemzés gráf-transzformációkkal

Szintaxis
Egy nyelv jelentéstől független struktúráját nevezzük szintaxisnak. Szintaxis-ról beszélhetünk természetes nyelvek és programozási nyelvek esetén is. Ide tartozik, hogy a szöveg hogyan bomlik eltérő szerepű szavakra és jelölésekre és hogy ezek milyen hierarchikus rendszert alkotnak. A nyelvészetben a konstituens fa, avagy szintaktikai fa reprezentálja a szöveg szintaxisát, ami a tokeneket kifejezésekbe, majd mondatrészekbe és mondatokba rendezi. Az NLP-ben e helyett a függőségi gráfok terjedtek el, amik a szavak között címkézett irányított élekből építenek egy irányított gráfot. Ebben a fejezetben ezt a két formalizmust fejtem ki részletesebben.

A Szintaktikai Fa

A nyelvészet szemlélete szerint bármelyik emberi nyelv szintaxisa leírható egy Környezetfüggetlen Nyelvtannal. 
Környezet Független Nyelvtannak egy G=(N,Σ,P,S) rendezett négyest nevezünk, ahol:
N  nemterminális ábécé
Σ  terminális ábécé amire N∩Σ=∅
S∈N 	a kezdőszimbólum
P  pedig α→β alakú átjárási szabályok véges halmaza, ahol  α,β∈(N∪Σ)* és α-ban van legalább egy nemterminális betű. 	 	
https://people.inf.elte.hu/kubuaai/FoNYa/formalis_nyelvek_kidolgozott_tetelek.pdf másik forrást
Ebben a nyelvtanban a terminális szimbólumok a szavak és az azokat tagoló írásjelek. A nemterminális szimbólumok három szintre sorolhatóak. A legalsó szint a szavak szintje, ahova a szófajokat és írásjel kategóriákat jelölő (nagyjából 40 féle) csúcsok tartoznak. Ezek a csúcsok átírásával közvetlen a terminális szimbólumokat kapjuk. A terminális szimbólumokat eredményező átírási szabályokat “terminális szabály”-oknak hívják. A második szint a kifejezések szintje, ahova a szavak alkotta kifejezéseket jelölő (nagyjából 20 féle) csúcsok tartoznak . Ezek a csúcsok írhatóak át a típusuknak megfelelő headerű kifejezésekké, amik további kifejezésekből és szavakból állnak. A harmadik szint a mondatrészek szintje, amihez a mondat egészét jelölő ‘S’(sentance) és a mondatrészeket jelölő négy további szimbólum tartoznak.  A kezdő karakter az S, mint “sentence”. Egy mondat akkor helyes szintaktikailag, ha létezik a környezetfüggetlen nyelvtanban levezetése. Ha létezik levezetése, akkor a levezetési fa maga a mondat Szintaktikai Fája. 
Ezek például a 2.2.4-es pontban található szintaktikai fa szabályai
 ( a “John loves Mary.” mondaté: S3( NP1( NNP( John ) ), VP2( VBZ( loves ),  NP1( NNP( Mary ) ) ), .( . ) )  ) :
S → NP VP .
NP → NNP
VP → VBZ NP
NNP → John | Mary
VBZ → loves
. → .
  A szintaktikai fa a legbevettebb reprezentációja a mondatok szintaxisának a nyelvészetben. Analitikus megközelítés esetén is legtöbbször a szintaktikai fa az első, amit elkészítünk. Ehhez először a szavakat feltokenezzük, avagy meghatározzuk a terminális szimbólumok határait és kigeneráljuk a megfelelő “szófaj token”-t mindegyikhez. Végezetül megkeressük valószínűségi súlyozásokkal gyorsítva a legvalószínűbb levezetését az adott nyelv átírási szabályai alapján.

UD és a dependencia elemzés

A dependencia alapú megközelítés szerint a szintaktikai szerkezet lexikai elemekből áll, amiket bináris kapcsolatok kötnek össze. A dependencia fogalma azt jelenti, hogy a szavak(fej és dependens) irányított kapcsolatokkal vannak összekötve.  Általában az állítmány a gráf gyökércsomópontja vagy a strukturális középpontja a mondatnak. A mondat szerkezetét a fejek és dependensek közötti viszonyok adják. Sok jól ismert elmélete van a függőségi nyelvtanoknak, összefoglalásért lásd (Nivre, 2005, p.  3).

Az UD(Universal Dependency) (UD weboldalát, (De Marneffe et al. (2014))) információt egy DAO gráfon szemlélteti, aminek csúcsai a szavak, és élei pedig a szavak közötti viszonyok. Az UD-hez hasonló Függőségi Gráfoknak sok féle formalizmusa létezik. Az NLP területén ezt a reprezentációt használják legtöbbször a szintaxis reprezentálására. Mi a kutatásunk során az UD-t használtuk.
Az UD projekt egy nyelvek közötti konzisztens annotációs rendszer és fa adatbázis hatvannál is több nyelvre. Kategóriák és annotációk univerzális készletét nyújtja miközben miközben megenged nyelvfüggő kiterjesztéseket is. A szavak közötti nyelvtani viszonyt szemlélteti, mint például az alany-állítmányi vagy tárgy-állítmányi vagy jelzői. Az UD a Stanford Dependencies (hivatkozás: (De Marneffe and Manning (2008)) fejlődött ki, amit egyesítettek a Google univerzális címkékkel (Petrov et al. (2011)), az “Interset feature inventory”-nak egy átdolgozott rész halmazával (Zeman (2008)) és  a CoNLL-X formátum egy átdolgozott verziójával (Buchholz and
Marsi (2006)).

példaelemzést LaTexben

Az alap függőségek két csoportba sorolhatóak. Az egyik csoport a klauzális (“clausal”) viszonyok, amik szintaktikai szerepeket írnak le a predikátumra vonatkozóan. A másik csoport a módosító viszonyok, amik azt írják le, hogy a fejet hogyan módosítja a függőben lévő szó. (Jurafsky and Martin (2018b)) Az egységes analízis okán a függőségek fejének a főnevet tekintjük, amit bemutat egy elöljáró vagy van hozzá csatlakozó. Más esetben a jelölőt tekintjük a függőség fejének. A formalizmus egy lexikalista megközelítést követ a számítás beli használat megvalósítására: a szintaktikai szerkezetek  lexikai elemekből állnak, amik aszimmetrikus egy az egyhez kapcsolatokkal vannak összekötve a hatókörrel ellentétben, ami egy egy a többhöz kapcsolat. (De Marneffe et al. (2014))Az UD lehetővé teszi dependencia parszerek nyelveken keresztüli kiértékelését. Több mint 30 csapat vett részt 2017-ben a közös céllal, hogy megvalósítsák a többnyelvű dependencia elemzést (shared taskos papert hivatkozd 2018).


szavak közötti viszonyok, angolul és jelölésük:
((Jurafsky and Martin, 2018b, p. 3))


itt meg lehetne olyan alfejezet, hogy “Szemantika”
írhatnád benne, hogy mi az a szemantikai elemzés, hogy lehet csinálni (shallow vs. deep, vektorterek vs. gráfos cucc), de az ilyen átvezető részeket segítek majd megírni, vagyis átírok majd egyet-kettőt, ha megírtad, de olyasmik legyenek, mint a szakdolgozatomban amik vannak

2.3
4lang


A 4lang  (Kornai et al. (2015)) egy formalizmus, ami irányított gráfokat épít szemantikai reprezentáció céljával. A gráfban a csúcsok nem szavakat, hanem nyelvfüggetlen fogalmakat jelölnek. Ezeknek a fogalmaknak már nincsenek nyelvtani jellemzőik és a kompetens beszélők közös tudását reprezentálja a fogalomról. Például a fagy \texttt{fagy} mit főnév vagy ige vagy fagyás vagy fagyott szava nincsenek megkülönböztetve a 4lang reprezentációban itt hivatkozzuk, akinél ezt a példát először olvastuk Ezáltal a 4lang fogalmak és a nekik egy nyelvben megfelelő szavak között egy a többhöz kapcsolat áll fenn.


A csúcsokat három féle él kapcsolhatja össze:
 0-él 	reprezentálja a tulajdonságokat. Például “virág -0-> 	szép”, az AZ_EGY(IS_A) viszony “virág -0->  növény” 	és unáris predikció “virág -0-> bimbózás”.
1 	és 2-élek bináris predikciókat kapcsolnak az argumentumaikhoz. 	Például “James <-1- szeretet -2> kutya”.
Binary 	(tranzitív) elemek, amik nem felelnek meg egyik szónak sem egy 	kifejezésben vagy mondatban, NAGY BETŰS nyomtatott nevekkel vannak 	jelölve.


Létezik egy másik él konfiguráció is, ami megjelenhet 4lang gráfban, w₁ <-0-1-> w₂ . Erre azért van szükség, hogy konzisztensen lehessen jelölni a tárgy és predikátum közötti viszonyt. Vegyük például a “I’am writing.”(“Én éppen írok”)  mondatot az “i -0> write” 4lang gráffal és az “I’am writing a letter”(“Én egy levelet írok éppen”) mondatot az “i <-1- write -2-> letter” gráffal . Ez a két példa a dupla él nélkül azt jelentené, hogy a két az “i” és a “write” között attól függ a viszony, hogy adott e a tárgy vagy sem. Recski (2018)
A 4lang könyvtár tartalmaz eszközöket, amelyek képesek 4lang gráfokat építeni Nyers Szövegből és Szótári definíciókból (text_to_4lang, dict_to_4lang). A mag modulja a 4lang könyvtárnak, dep_to_4lang, 4lang viszonyokat nyer ki szövegből, a Stanford Parser (DeMarneffe et al. (2006)) kimenetének a feldolgozásával és a Stanford függőségeknek a leképzésével 4lang részfáká.
4lang a neve egy kézzel alkotott  fogalmi szótárnak is, ami négy nyelven tartalmazza nyelvfüggetlen fogalmak több mint 2000 definícióját (magyar, angol, latin, lengyel). Kornai and Makrai (2013))


ezt majd lehet hogy átrendezzük másik alpont alá, de amit írsz, az tök oké
A 4lang és az UD különbségei

A munkánk során mint majd alaposabban is bemutatom a nyelvtan generálásánál, alaposan kihasználtuk a 4lang és az UD közötti hasonlóságot. Mindkét esetében egy irányított gráfról beszélünk. Mindkét esetében a csúcsok megfeleltethetőek a szavaknak, és az élek szavak közötti viszonyokat jelölik. Maguk a függőségek is sok esetben megfeleltethetőek egymásnak. Például a w₁ -amod-> w₂ viszony az UD-ból megfelel a w₁ -0-> w₂ viszonynak a 4lang-ból.
A kettő között ugyanakkor fontos elméleti és jelölésbeli különbségek vannak. Az UD a mondatok szintaxisát reprezentálja, míg a 4lang a szemantikai jelentését. Az UD-ben a csúcsok maguk a szavak, míg 4lang-ban a szavaknak megfeleltethető fogalmak. Az UD élei a szavak közötti nyelvtani viszonyt jelölik, addig a 4lang élek a szavak közötti szemantikai függőségekket. A 4lang függőségek és az UD függőségek között egy a többhöz viszony áll fenn, ahogy a szavak, és a 4lang beli fogalmak között is. Ez persze azt jelenti, hogy az UD már tartalmazza a szemantikára vonatkozó információkat is, de csak közvetetten.

UD-4lang megfeleltetéses táblázat

Bár a mondat UD gráfjából a 4lang gráfja levezethető, a két formalizmus tartalma mégsem ekvivalens. A 4lang gráfból már nem mindig vezethető le egyértelműen az UD. Az UD szavairól pedig nem egyértelmű, hogy a 4lang mely fogalmaira vetítsük le őket. A több jelentéső szavak is nehezítik a helyzetet, mivel ekkor a szónak megfelelő fogalom már függ a szó környezetétől is. A projekt jelenlegi fázisában még nem foglalkoztunk a szavak és 4lang fogalmak megfeleltetésével. Még nem áll rendelkezésünkre erre automatikus módszer. Mivel egy nyelv szókészlete és szavainak jelentése is állandóan változik, teljsen elvetendő a a megfeleltetésekhez szükséges adatok manuális előállítása.

A kutatás célja

A kutatásunk célja az, hogy a nyers szöveg és a feljebb leírt interpretációk bármelyikéből le tudjuk a többit generálni. Ha az egyik interpretációhoz a másikból több is tartozik, akkor képesek akarunk lenni az összes verziót legenerálni és a legalkalmasabbat automatikusan kiválasztani valószínűségi súlyozás segítségével. Minél kevesebb nyelvet szeretnénk használni, és minél kevesebb módszertant. Ez utóbbi szemponttól azt várjuk, hogy könnyebb lesz a kódot karbantartani és bővíteni további interpretációkkal. Mind ezt hatékonyan is szeretnénk csinálni. E téren az alap célunk egy négyzetes lefutási idő a bemenet méretének függvényében. Ezeknek a megkötéseknek az IRTG nyelv eleget tesz. Hiszen nagyon eltérő interpretációk esetében is legfeljebb interpretációk száma plusz egy nyelvet kell használnunk. Ugyanakkor, ha kiegészítjük az IRTG-t egy összetettebb gráf algebrával, az képes lehet minden interpretáció hatékony leírására és mindehhez két nyelvet kellene használnia.


Az IRTG és az alárendelt algebrák

Ebben a fejezetben a kutatás során használt környezetről(ALTO), formalizmusról(IRTG), algebrákról(SA,TTA,SGA), hátrányaikról és az ezeket kiküszöbölő ideiglenes megoldásainkról lesz szó.

Az ALTO

A kutatás során a kódot az Algebraic Language Toolkit-tel, avagy ALTO-val fordítjuk és futtatjuk. Az ALTO egy nyílt forrású parszer, ami többféle algebrát is megvalósít, ami IRTG-be ágyazva használható. 
Ezek egyike az s-graph és a tag tree algebra. Ezen kívül is szabadon bővíthető új algebrákkal. Már korábban is használták gráf transzformációra és szemantikai feldolgozásra is. Nagy előnyt jelent, hogy Java-ban lett implementálva , így szinte bármely platformon futtatható. Ezen kívül rendelkezik grafikus és konzolos felhasználói felülettel is.


Az IRTG

Az IRTG (Interpreted Regular Tree Grammar, Interpretált Reguláris Fa Nyelvtan) egy kontextusfüggetlen nyelvtan, ami egy vagy több algebrába beágyazott újraíró szabályokból áll. 

NP -> _NP2_amod_JJ_NN(JJ, NN)
[string] *(?1,?2)
[tree] NP2(?1, ?2)
[ud] merge(f_dep(merge("(r<root> :amod (d<dep>))", r_dep(?1))),?2)
[fourlang] merge(f_dep(merge("(r<root> :0 (d<dep>))", r_dep(?1))),?2)

1. ábra: Egy, a amod relációt leíró IRTG-szabály négy algebrával

A szabálysorok egy környezetfüggetlen nyelvtan átírási szabályait adják meg. A szabályok feldolgozásakor először egy levezetési fa (derivation tree) épül, amelyek a nonterminálisokat lecserélő szabályokat tartalmazzák. Egy szabályt a következő módon lehet definiálni (a sablonban a változó részeket {$ $} zárójellel jelöltem, ahol a $ a Slot kifejezésből ered, a {} pedig a nem szöveg elemeket jelöli):

[{$interpretáció neve$}] {$interpretáció lépése$}

A interpretációk nyelve és kimenete többféle is lehet.  Választható például a szöveg kimenetű String Algebra, a csúcs sorrendet tartó fa gráf kimenetű Tag Tree Algebra, vagy  az irányított gráf kimenetű S-graphAlgebra. Az algebrák és az interpretációk között egy a többhöz kapcsolat van. Az interpretációk egymástól teljesen függetlenek. Egy szabályban minden interpretációt meg kell adni. Minden átírás során, minden interpretációra vonatkozó derivációba beszúródnak az alkalmazott szabályban az interpretációhoz tartozó lépések. A beszúrás helyét ?{$ szám $}-ként jelölik minden interpretációban. Itt a szám annak a jobb oldali nemterminálisnak a sorszáma, amely az interpretációhoz tartozó lépése szúródik be a jelölt helyre az átírása során. Az IRTG futtatásakor bármelyik interpretáció lehet a bemenet. Az ALTO a bemeneti interpretáció algebrájának megfelelő formátumú bemenetet vár. A futás során az ALTO keres a bemenethez egy olyan levezetést, ami megfelel a Környezet Független Nyelvtannak és a bemenetet adja eredményül. Ezt követően a levezetési fa szerint felépíti a többi interpretációt is és végrehajtva őket előállítja a kimeneteket.

Tekintsük az 1.ábrán bemutatott szabályt. Ez a szabály egy Melléknévből (Adjective,JJ) és egy Főnévből(Noun,NN) készít egy két gyermekű Főnévi Kifejezést(Noun Phrase, NP). A két szó között Melléknévi Módosítói(Adjectival Modifier, amod) viszony áll fenn az UD gráfban. Ennek megfelelően neveztük el a szabályt “_NP2_amod_JJ_NN”-nek. Az első reprezentációk sorban a Nyers Szöveg, a Szintaktikai Fa, az UD Gráf és a 4lang Gráf.
Itt minden reprezentációban a “?1” és “?2” az ahova a “JJ” és “NN” jobb oldali nemterminális szimbólumok átírásánál keletkező kifejezések kerülnek. Ezek az interpretációk bemenetei. Jelen esetben a “?1” a “JJ” és a “?2” az “NN” szimbólum interpretációinak a helye. A két jobb oldali Nemterminális kiértékelése után minden interpretációba a vele azonos interpretáció kimenete kerül, string-é a stringbe stb..

A string interpretációhoz a String Algebra tartozik. Jelen esetben a bemeneti két szót fűzi össze. A tree interpretációhoz a Tag Tree Algebra tartozik, ami egy “NP2” címkéjű csúcs alá szúrja be a két bemenetet. Ez az algebra állítja elő a Szintaktikai Fát. A bemenete két-két csúcs.  A negyedik és ötödik sorhoz is az S-Graph Algebra tartozik. Mindkettő irányított éllel köti össze a két bemenetet. Az UD egy amod, a 4lang pedig egy 0 címkéjű éllel. Itt mindkét esetben mindkét bemenet csak egy címkézett csúcs. A nevüknek megfelelő gráfokat állítják elő.. Magasabb szintű szabályoknál már a ud és 4lang bemenetek összetett irányított gráfok lesznek. Mi elsősorban az előbb említett  három algebrát  használjuk, de ezeken kívül más algebra is használható az IRTG nyelvben, mint például… alto wiki. Ezek nem részei a dolgozat fókuszának.

Az SA

Az SA(String Algebra) kétségtelenül az összes IRTG alatt elérhető algebra közül a legegyszerűbb. Itt csak szövegek konkatenációjára(összefűzésére) van lehetőség. A bemenet és kimenet nem tartalmaz slotokat vagy egyéb nyelvi elemeket. A műveletet a következő formátumban lehet megadni:
*( {$ szöveg1 $}, {$ szöveg2 $} )
Egymásba is ágyazható több konkatenáció:
*( {$ szöveg1 $}, *( {$ szöveg2 $}, {$ szöveg3 $} ) )
Például a *( “Every mouse”, *( “loves”, “cheese.” ) ) kifejezés az “Every mouse loves cheese.”, avagy  “Minden egér szereti a sajtot.” szöveget adja vissza. Ez a konkatenáció kommutatív és asszociatív.

A TTA

A TTA(Tag Tree Algebra) nak, mint az SA-nak, csak egy művelete van, az merge(egyesítés). A TTA esetében viszont  már a bemenetek nem nyers szövegek, hanem csúcs sorrend tartó fa gráfok. Tartalmazhatnak slot-okat, amiket TTA esetében Hole-nak(lyuk) nevezünk. A Hole-okat ‘*’-al jelöljük. Nem lehet őket címkékkel vagy más módon megkülönböztetni sem eltörölni. A gráf csúcsaiba helyezhetőek. Az ilyen slot-okat tartalmazó fákat nevezzük Tag Tree-nek. A TTA merge műveletének két operandusa van. Mindkét operandus egy Tag Tree. A jobb oldali fát szúrjuk be a bal oldali fa minden hole-jába a merge során. A merge jele a ‘@’ szimbólum, és se nem kommutatív, se nem asszociatív. A fákat zárójelekkel adjuk meg. Egy csúcs közvetlen gyermekeit és az azok alatti részfát a tőle jobb oldali zárójelben kell megadni vesszőkkel elválasztva. Például így írható le jól bevált “John loves Mary.” (“János szereti Marit.”) mondat Szintaktikai Fája:
S3( NP1( NNP( John ) ), VP2( VBZ( loves ),  NP1( NNP( Mary ) ) ), .( . ) )
, aminek ez a fa felel meg:

Ugyanez az igés kifejezés, avagy a VP(Verbal Phrase) helyén hole-lal:
	S3( NP1( NNP( John ) ), *, .( . ) )
A fenti gráfba a VP2 beszúrása merge-dzsel:
	@(S3( NP1( NNP( John ) ), *, .( . ) ),  VP2( VBZ( loves ), NP1( NNP( Mary ) ) ) )
Ennek a műveleti fája:


A TTA egy egyszerű, de átlátható és jól kezelhető nyelv. Ugyanakkor nincs arra lehetőség, hogy a jobb oldali gráfot a baloldali gráfnak csak adott csúcsába szúrjuk be. A bal oldali gráf minden lyukát felhasználjuk a merge művelet során. Ez már a három gyermekű csúcsok esetében is komoly nehézséget jelentett számunkra. Négy gyermekű csúcsok esetében egyenesen ellehetetleníti a két bemenetű szabályok használatát, amikre a hatékonyság végett törekszünk.
Például ha van már egy szavak nélküli:
S3( NP1( * ), VP2( *,  NP1( * ) ), * ) 
fánk, akkor abból sose leszünk képesek az eredeti:
S3( NP1( NNP( John ) ), VP2( VBZ( loves ),  NP1( NNP( Mary ) ) ), .( . ) ) 
fát előállítani, mert már az első szóhoz tartozó csúcsok, az “NNP(John)” beszúrása esetén az:
 S3( NP1( NNP( John ) ), VP2( NNP( John ),  NP1( NNP( John )) ), NNP( John ) ) 
fa gráfot kapjuk. Éppen ezért a interpretációs lépések segítségével kell összerakni szabályról szabályra ezt a fát. Lásd [Példa 1].

Ez a példa is jól mutatja, hogy egy két gyerekű csúcsot, mint a VP2 össze tudunk rakni egy két bemenetű szabályban. Egy három gyerekűt, mint az S3 már nem, hiszen a három gyereket nem tudja mind megkapni egyszerre. Ekkor kénytelenek vagyunk két szabály alatt előállítani a szerkezetet merge használatával. Az ilyen három gyermekű csúcsok gyakoriak a Penn Treebank Szintaktikai Fáiban.  Ilyen a “the black cat” (“a fekete macska”) Főnévi Kifejezés is, aminek a Szintaktikai Fája az: 
NP3( DT( the ), JJ( black ), NN( cat ) ). 
A fát Merge nélkül praktikusan csak három bemenetű szabállyal lehetséges implementálni.
Lásd [Példa 2].

Merge segítségével sokkal optimálisabban is megoldható. Lásd [Példa 3].

Négy gyermekű főneves kifejezések esetében ez már nem lehetséges. Ilyen például a “this British industrial conglomerate”(ez a brit ipari összetömörülés), amihez  a:
NP4( DT( this), JJ( British), JJ( industrial), NN( conglomerate) ) 
 fa tartozik. Ezt a fenti logikával nem tudjuk helyesen megoldani. Lásd [Példa 4].

Itt a második NP_BAR elkészítésekor, a merge művelet során a JJ  mindkét lyukba beszúródik, így a: NP4( DT( this), JJ( British), JJ( British), NN( conglomerate) )
Ezt a TTA korlátai miatt nem tudjuk megkerülni.

Négy gyermekű csúcs egy helyes szintaktikai fában nem fordul elő. A középső JJ-k helyes esetben egy ADJP-t alkotnának. Mi a Stanford parser kimenete alapján dolgoztunk, ami sok esetben ilyen fát adott eredményül.

Az SGA

Az SGA(S-Graph Algebra) a legbonyolultabb algebra, amit használunk. Több műveletet és összetett gráf nyelvet használ. Az egyetlen hiányossága, hogy nem képes a csúcsok sorrendjét kezelni. Ezért szorulunk a TTA használatára csúcs sorrend tartó fák esetén. Az SGA-ban egy csúcsnak három attribútuma van, name(név), tag(címke) és mark(megjelölés). Ezeket a következő szintaxissal tudjuk megadni: {$ name $}/{$ tag $}<{$ mark $}>. Az attribútumok közül a tag és a mark elhagyható. A név azonosítja a csúcsot adott környezetben, a címke jelenik meg a gráf kirajzolásakor és a jelöléssel hivatkozhatunk a csúcsokra egyes műveletek során. Az éleket :-tal jelölik, és címkézhetőek. Alapesetben az él balról jobbra mutat, de van mód jobbról balra mutató él definiálására is. A gráfokat string ként kell megadni Például a: 
“(ROOT :root (loves/loves :nsubj (John/John) :dobj (Mary/Mary) ) )” 
a “John Loves Mary.” mondat UD Gráfját írja le, ami így néz ki:

A nyelvtan legfontosabb három művelete a forget( elfelejt ), rename( átnevez ) és a merge( egyesít ). A forget és a rename a jelölések manipulációjára való. A forget művelettel lehet egy jelölést az összes vele megjelölt csúcsról törölni. A rename művelettel egy adott jelölés minden megjelölt csúcson lecserélhető egy másik jelölésre. A merge művelet bemenete az előzőekkel ellentétben két gráf. A bal oldali gráf minden megjelölt csúcsába beszúrja a jobb oldali gráf minden ugyanazzal a jelöléssel megjelölt csúcsát. A műveletek egymásba ágyazhatóak. Csak az egymást követő forget műveletek cserélhetőek fel minden esetben. Forget-et a “f_{$ jelölés neve $}({$ gráf $})” formában lehet megadni, ahol természetesen a gráf helyén állhat újabb művelet is.  Rename-t pedig a: 
r_{$ régi jelölés $}_{$ új jelölés $}( {$ gráf $} )
formátumban lehet megadni. A Rename esetén a leváltandó jelölés neve elhagyható és abban az esetben a “root” jelölésű csúcsokon fogja végrehajtani. A merge formátuma hasonlít leginkább a közismert programozási nyelvek függvényhívásaira.: merge({$ gráf1 $}, {$ gráf2 $} ). Lásd [Példa 5].

A példa sok szabálya megfeleltethető a tree reprezentáció esetében használttal. Ennek oka az, hogy a nyelvtanokat úgy írtuk meg, hogy azokat könnyű legyen összeilleszteni. Általában a Szintaktikai fa egy csúcsát vagy egy három gyermekű csúcsának a felét rakjuk össze egy szabály alatt, és az UD Gráf-ba kerülő élek és a jobb oldali nemterminális szimbólumok szerint nevezzük el a szabályokat. Mivel az UD Gráfban és 4lang Gráfban sok a hasonlóság, azt is hozzá adom az egyesített nyelvtan példában. Lásd [Példa 6]

Az S-Graph algebra egy jól használható nyelv, de módosítani és javítani is nehéz. Ennek elsődleges oka a bonyolult szintaxis.
A műveletek nehezen átláthatóak. A legtöbb művelet jele egy-egy betű, és így se nem olyan beszédes, mint az aritmetikai operátorok, se nem olyan felismerhető, mint az SGA merge vagy a TTA ‘@’ jelölése. Az operandusok egy részét is a függvény nevében jelölik.  Ez mind sokat ront az átláthatóságon. Sok esetben fölösleges, hogy külön művelet a forget és a rename a merge-től. Egyszerűbb lenne a merge attribútuma ként megadni, hogy a bal oldali gráfból milyen jelölést párosítunk a jobb oldali gráf melyik jelölésével. Azt is lehetne opcionális operandus, hogy a merge után melyik mark legyen elfelejtve. 
Ha már a nyelv célja egyértelműen a tömörség, akkor a merge lehetne ‘@’ a TTA-hoz hasonlóan. A forget és a rename is lehetne pl. ‘&’, mint reference, ‘#’, ‘%’ vagy egyszerűen egy ‘R’, ahol a forget egyszerűen egy olyan rename, ahol az új jelölés hiányzik és nem a régi.
A “:” semmilyen asszociatív viszonyban nincsen az irányított élekkel. A ‘:’-ot lehetne például “-{$él címke$}-”-re cserélni irányfüggően kacsacsőrökkel a végén.
A csúcsok deklarációjában az attribútumok egymástól teljesen eltérő szintaxissal vannak jelölve teljesen feleslegesen. A csúcsok adatai is mehetnének egy szögletes zárójelbe. A zárójelen belül 
[n={$ name $} , t={$ tag $} , m={$ mark $}] formában egyértelmű is lenne, hogy melyik melyik. Így a sorrendjük lehet cserélhető. Így bármelyikük elhagyható anélkül, hogy zavaróvá válna. Itt attribútumok felsorolásáról van szó, így a kis betű sem zavaró. Adott sorrend mellett a kis betűk is elhagyhatóak: 
[{$ name $} | {$ tag $} | {$ mark $}].
Lásd [Példa 7]

Véleményem szerint ez sokkal tisztább módja lenne és tördelni is sokkal egyszerűbb. Ha az egyik forget vagy rename műveletetre nincs szükség, akkor csak elhagyjuk a hozzá tartozó attribútumokat . Még ennél is szebb lenne, ha a műveleteket operációs jelek jelölnék. Lásd [Példa 8]

Ugyanakkor ez már túlzottan eltér a gráfleíró nyelvek hagyományos stílusától, és tördelni is nehézkesebb. Operátoros esetben pedig szükség lenne egy sorrendiségre is, ami nem lenne mindenki számára triviális. Arról nem is beszélve, hogy a rename művelet három bemenetű, így nem lehet egy operátorral elvégezni, ahogy az összetett merge négy operátorát is erőltetetten hat.

Az IRTG és az ALTO hiányosságai

Az IRTG hiányosságai

Az IRTG nem egy programozási nyelv, hanem egy nyelvtan. A szabályok egymás alatt adhatóak meg és csak backspace karakterekkel és kommentekkel tagolhatóak. Egy nyelvtan több fájlra nem szedhető szét. A fájl elején fel kell sorolni az interpretációkat, és egyik interpretáció sem hagyható el egyik szabályból sem, még akkor sem, ha semmit sem adnak vissza. A kutatás során egy olyan nyelvtant készítettünk, ami 2700 szabályból áll és négy interpretációból. Ez ha a szabályokat üres sorokkal választjuk el, akkor 16204 sor kódot jelent egyetlen fájlban. Egy ekkora kódot nehéz karbantartani, átlátni, fejleszteni. Tehát szükség van IRTG-ben az importálásra

Rengeteg esetben a szabályok alig egy-egy szóban térnek el. Lásd [Példa 6.]
Itt a “John” és a “Mary” szóhoz tartozó terminális szabályok között csupán maguk a szavak jelentik a különbséget. A String interpretációban is csak maga a szó jelenik meg. Más szófajú szavak esetében is csak a szabály sort és tree reprezentációt kell még módosítani. Az ilyen esetek miatt nagy kár, hogy az IRTG-ben nem lehet szabályokat egymásból vagy egy közös ősből származtatni.

Sokszor egy szó szófaja egy másik szófaj alkategóriája. Ilyen például az NNP(), ami az N() alketegórája. Az egy főkategóriába tartozó szófajok sok esetben ugyanúgy viselkednek. Például egy NP-ben, ami egy N-ből és egy JJ-ből áll, minden esetben a két szó között egy amod él lesz az UD gráfban. Ugyanakkor vannak olyan esetek is, amikor az alkategóriáknak csak egy részhalmaza viselkedik hasonlóan. Egy alkategória esetében két féle képpen lehet megoldani ezt. Az egyik verzióban általánosítunk, avagy az alkategóriákat ugyanúgy kezeljük. Ekkor jelentős áldozatot hozunk a pontosság terén. Más esetben minden egyes alfajra előállítunk minden szabályt, amivel előfordul. Ekkor jelentős áldozatot hozunk hatékonyság terén, mivel sokkal több szabályon kell végig iterálnia az ALTO-nak az IRTG futtatásakor. Erre jó megoldás lenne, ha egy szabálysorban minden olyan nemterminális szimbólumot meg tudnánk adni, amire a szabálynak minden interpretációhoz ugyanaz a lépés tartozik. Erre jó megoldás lenne, ha a szabálysorban regex-xel lehetne megadni mindegyik jobb oldali nemterminális szimbólumot.

Az IRTG szabályokban mindenre más és más algebrát használunk más és más nyelvvel. Ennek az az oka, hogy mint már az algebráknál részleteztem, minden algebrának vannak hiányosságai. Az IRTG maga lehet önmagában átlátható, de ha az algebrái sokfélék, és némelyiket önmagában is nehéz átlátni, akkor az az IRTG-re is közvetlen hatással lesz (lásd s-graph algebra). Hiába a sokféleség, ha egyes feladatokra csak egy olyan algebra létezik, ami megfelel a célnak és az is erősen korlátozott. Egy algebrára van csak szükség. Egy olyan algebrára, ami az s-graph algebra szintjén van, de átlátható és képes mint a csúcsok sorrendjét kezelni, mint a címkék konkatenációját. Elvégre a szöveg is kezelhető egyetlen csúcs ként. Egy ilyen algebrában az is fontos, hogy ne kelljen az egyszerű műveleteket sokkal terjedelmesebben megoldani, mint ha azt az egyszerű algebrákkal végeznénk. Az s-graph javítására az algebra kapcsán mutattam példát, de egy ilyen univerzális algebra már szemantikai változtatásokat is igényelne.

Gyakori az IRTG-ben az, hogy kulcsszavak ütköznek pár változónak a nevével, ami felesleges errort okoz a feldolgozás során. Például az “interpretation” szóhoz generált terminális szabályunk ütközött az interpretation szóval, amivel kezdődnek az IRTG fájlok elején az interpretációkat definiáló sorok. Ha a szabálynak így kezdődik a neve, akkor már nem fogadja el a futtató környezet. Erre a legegyszerűbb megoldás az, ha a nyelvben megjelenik a szöktetés, vagy a kulcsszavakat úgy módosítjuk, hogy ritka speciális karaktereket is tartalmazzanak. Például, ha az “interpretation” helyett “<interpretation>” lenne a kulcsszó.

Az ALTO hiányosságai

Az ALTO működése iteratív. Végig iterál az összes lehetséges levezetési fán a környezetfüggetlen nyelvtanban, és kiválogatja a bemenetre illeszkedőeket. Ez alatt persze különböző módszerekkel igyekszik elkerülni azokat a lehetséges levezetéseket, amiről már tudja, hogy biztos rosszak lesznek. Erre az egyik legegyszerűbb módszer az, ha a levezetési fákat fentről lefelé generáljuk és kihagyjuk azokat a lehetőségeket, amik már magasabb szinten olyan élet vagy csúcsot vagy azok olyan halmazát vesznek be a derivációba, ami a bemenetben nem szerepel. Ennek neve is van, erről kaptam forrást is.

Az elvi működés és a megvalósítás következtében az ALTO rendkívül lassú. A feljebb említett 2700 szabályos és négy interpretációs nyelvtan 10^5 nagyságrendű adaton nagyjából 30 óráig futott, pedig a rendelkezésünkre álló tanszéki szerveren futtattuk. Ez a mi feladatunk esetében elfogadhatatlan. Ezért nem ártana egy hatékonyabb c++ verzió az ilyen méretű munkákhoz. Ma már a C++17 és a hamarosan érkező C++20 is kényelmes programozási nyelv, és nem nagy ördöngösség az alap platformokon futtatható verziókat legenerálni a nyílt forráskódból. Egy könyvtár formájában pythonból is elérhető lenne ez a verzió.

Az ALTO rengeteg felesleges munkát végez, mivel azokat a megoldásokat is ki generálja a bemenetből, ami más interpretációk derivációjában errorhoz vezet. Az ilyen eseteket is ki lehetne szűrni már a derivációs fa magasabb szintjének az iterációja során. Persze ez debuggolás szempontjából káros, mivel az ilyen esetek kiszámítása nélkül nem tudjuk megfejteni, hogy mi okozta a hibát, de mérvadó méretű adatot nem is akkor fogunk futtatni. Jó lenne, ha ez opció ként lenne elérhető.

Az ALTO mindennek ellenére a jelenlegi legfejlettebb program az IRTG futtatására, és állandó fejlesztés alatt áll. A pontos működését még nem ismerjük. A módosítások többsége viszont a belső működés alapos átdolgozását igényli. Erre jelenleg még nincs erőforrásunk.

Ideiglenes megoldások

 A kutatás során az IRTG-t illető problémák többségét kód generálás segítségével küszöböltük ki. Két implementáció készült python nyelven, amik bemeneti adatokból generáltak irtg szabályokat. Kezdetben csak NP-k feldolgozása volt a cél, majd onnan terjesztettük ki az implementációkat VP-k és ADJP-k re. A generátor kódos megoldások legfőbb hátránya a fejlesztőhöz kötöttség volt. Nem tudtunk többen párhuzamosan fejleszteni, mert egyikünk sem értette a másik megoldását kellő mélységben.
Mindkét megoldás a Stanford Parser a Penn Tree Bank ből kapott kimenetét használta fel bemenetnek, amiket python scriptekkel készítettünk elő . Ezek a scriptek végezték a fákból a megfelelő kifejezések részfáinak a kiszedését, a részfák rendezését típus szerint és a fák UD gráfjainak a generálását a Stanford Parser-rel.

első generátor

Az első generátort én készítettem el 2018 augusztusában. Ez egy objektum orientált megoldás volt. Képes volt kommenteket is generálni, kezelni a rövidítéseket és könnyen bővíthető volt. Ugyanakkor  rush development során keletkezett a szakmai gyakorlatom végén, így a kód még nincsen se letisztázva, se alaposan dokumentálva.

Külön osztályban tárolta a nyers szöveg szavait , a fát és  az UD-t, majd ezeket rendezte egy közös osztályba. A közös osztály a Data, a nyers szövegé a Terminal, fáé a Tree, a UD-é és a 4lang-é a Dependency. Az összes osztály rendelkezett saját szöveg bemenetű konstruktorral, ami közvetlen a bemeneti adatok formátumából inicializálja az osztájt. 

A Terminal egy szót tárolt és annak a szófaját. A Tree tartalmazta a részfát a Stanford parser formátumában, a TTA formátumában, a TTA formátumában levelek nélkül és külön a szavakat. A Tree legtöbb formátuma csak a kommentek generálásához volt hasznos, de ideiglenesen mindegyiket generálta a program a kommentek végleges formátumától függetlenül. A Dependency tárolta a fej szavat, a függő szavat, az él UD típusát és az él 4lang típusát. Az UD él 4lang-ra vetítését a Fourlang enum és egy dictionary segítségével végezte. Mint korábban említettem, a szavak és 4lang fogalmak megfeleltetésével még mai napig sem foglalkozunk, de az is ebbe az osztályba került volna és feltételezhetően szintén egy dictionary és enum segítségével.

A generálás innentől szöveg konkatenációból áll az adatok függvényében. 
A kifejezés generátor függvények először betöltötték az adatokat a Data osztályokba, majd kiszűrte az egyedi adatokat a levél nélküli fák és UD élek alapján. Az komment első sorát a szerint generálta, hogy van e kapcsolat a szavak között és hogy a fej vagy a függő van előrébb. Ez a sor azt írta le, hogy milyen kifejezést milyen típusú szavakból épít a szabály és, hogy a dependens milyen szerepet lát el a mondatban. Ehhez az adatok rövidítéseit a Short2Long osztály segítségével oldotta fel, aminek a betöltendő adatai  a viszonylag kevés féle szófaj és él típus okán kézzel készültek. A következő két komment az első példány TT-jét és Stanford tree-jét tartalmazta. A szabály sort az adatokból nem volt nehéz legenerálni, mivel a szabályok neveit eredetileg is a bemenetek TT interpretációjának gyökere és az UD élek alapján képeztük. A string és tree sor csak a szabály bal oldali nemterminális szimbólumától függ, így azok konstans szövegek voltak. Az UD-nél a szövegbe csak az él nevét kellett beszúrni attól függően más sablonba, hogy a csúcsok között van e kapcsolat, megjelenik e mindkettő az UD gráfban(a “the”,”a” és “an” szavak például nem), és hogy ha van köztük kapcsolat, akkor melyik a fej. A fourlangnak ezek a tulajdonságok már bele voltak kódolva az enum alapú típusába, így itt csak egy else-if ágazaton kellett végigmenni (mivel pythonban nincsen switch case).

Már itt is látszott, hogy számos lehetőség van optimalizációra. Például a kódba ágyazott adatokat is ki lehetett volna szervezni txt fájlokba. Így a fourlang if-else ágai is megoldhatóak lettek volna egy dictionary-vel és karbantarthatóbbak lettek volna az adatok. A kettő magas kifejezések részfái között rengeteg volt a hasonlóság, így könnyedén össze lehetett volna a generáló függvényeiket vonni. A magasabb kifejezés részfákat se lett volna sokkal nehezebb ugyanabban a függvényben generálni. Az adatok feldolgozását és tárolását egy osztályban is meg lehetett volna oldani, ha a bemeneti adatok egy közös fájlban vannak. A nagyon sokadlagos adatokat, mint a fák stanford és 4lang formátuma, nem kellett volna eltárolni. Elég lett volna, ha a többi adatból származtató függvényeket is tartalmazza az egy darab Data osztály. Ezzel azt a duplikációt is elkerülhettük volna hátrány nélkül, hogy a terminálisokat majdnem mindegyik adatstruktúra eltárolta.

Végeredményben viszont még ekkor is egy olyan programunk lett volna, ami az IRTG kódot csak generálja. Végső soron templatelést használt volna, de az IRTG nyelvhez kötött szinten. Az új szabály egyre több kódot jelentett volna, és nehéz lett volna a hibákat meghatározni bárkinek, aki nem dolgozott a program elkészítésén és nem tanulmányozta hosszabb távon.

A második generátort Ács Evelin kezdte el fejleszti 2018 őszén, mivel bár értette az első generátor működését, nem látta át a teljes kódot, és én már nem dolgoztam a projektben, hogy letisztázzam és alaposan ledokumentáljam azt. A generátor vívmánya, hogy az adatokat struktúra ként kezeli.

A bemenet ennél a generátornál a Stanford fák és a hozzájuk tartozó UD gráfok, amiket fa ként és gráf ként kezel. A többi adat többségét, mint a templateket és UD-4lang párokat, külső fájlokban tárolja. Ennek a generátornak is a template-lés az alapelve, ugyanakkor egy kevésbé objektum orientált megközelítést követ. Itt egy szabály adatai egy Dictionary-ben vannak tárolva, amiket egy Dictionary-be gyűjt, amiben a szabály neve a kulcs.
A terminálisokat egy külön script generálja. Külön kezeli az unáris, bináris és ternáris szabályokat.
Az unáris szabályokhoz egyszerűen végig iterál a fákon és kikeresi az egy gyermekű csúcsokat, amiknek a gyermeke nem levél. Kigyűjti a csúcs és a gyermeke címkéjét, és beilleszti egy ilyen sablonba:
{$szülő címke$} -> _{$szülő címke$}_unary_{$gyerek címke$}({$gyerek címke$})
[string] ?1
[tree] {$szülő címke$}(?1)
[ud] ?1
[fourlang] ?1
A binárisokat és trenárisokat egy algoritmus kezeli. Ez az algoritmus először az UD gráf élein iterál végig. Veszi minden élet, a fejét és a dependensét. A két csúcs címkéjéhez tartozó szavakat és azok közös ősét kikeresi a szintaktikai fából. Ez után összegyűjti belőle a következő adatokat: 
ős : Mi az ős címkéje?
darab : Hány gyermekű az ős?
gyermek1, gyermek2(, gyermek3): Az ős-nek mik a gyermekei?
ős1, ős2: Az ős melyik gyermekeinek leszármazottja a két szó?
szó1,szó2 : Mi a két szó?
sorrend: Mi a sorrendjük a fában?
ud: mi az UD él címkéje?
4lang: Mi az UD-nek megfelelő 4lang struktúra? (ezt az UD adatokból származtatja)


Bizonyos esetekben, mint egy case struktúra, a 4lang szabály egy harmadik csúcstól is függhet. Case esetében ezt kihagyjuk a 4lang-ból és egy HAS csúccsal helyettesítünk.

Az “ősgyermek”-ekre csak a trenáris szabályok generálása esetén van szükség és a szabály sorhoz. Az is fontos merge szabályok esetében, hogy az ős gyermekek szomszédosak-e. Mivel a két bemenetű szabályokra törekszünk, a trenáris szabályok két szabályból állnak, egy BAR és egy MERGE szabályból. A BAR generál egy TT-t két részfát és egy lyukat egy megfelelő címkéjű csúcs alá rendezve. A MERGE szabályok merge-lik a harmadik részfát ebbe a fába. Ezért a két ősgyermek pozíciójától függ, hogy a generált szabály egy BAR vagy MERGE szabály.

A szükséges adatokat ebbe a templatbe illesztjük a fejléc sorok generálásához:
{$ős$} -> _{$ős$}{$darab$}_{$ud$}_{$ős1$}_{$ős2$}({$ős1$},{$ős2$})"
Itt az őshöz BAR esetben a “_BAR” is hozzákonkatenálódik, és merge esetben a szabály neve a “_MERGE” kifejezést is tartalmazza.

Ebben a verzióban a kommentelés és tagolás a legnagyobb hiányosság. Bár a projekt jelenlegi tagjai jól átlátják a szabályokat, a szükséges háttér nélkül nehéz a 2700 szabály között eligazodni. Ezt persze nem lenne nehéz megoldani, mivel a szükséges adatok már rendelkezésre állnak. Ha a szabályokat a baloldali szimbólum szerint és a közös ős fokszáma szerint csoportosítjuk, akkor a tagolás sem nehézkes. Persze itt is a Merge és a BAR szabályok külön kategóriát képeznek. A szabályok jelenleg gyakoriság szerint vannak sorba rendezve de a név szerinti sorba rendezés is sokat segítene. A kategóriákat mélység szerint is több főkategóriába lehet rendezni.

A kódot legtöbben itt sem látjuk át, mivel még részletes dokumentáció nem készült. Az UTLE első verziója nem lesz képes ilyen gráf műveletekre, de könnyű lesz benne olyan kódot készíteni, ami mindenki számára érthető, aki az IRTG-t és az UTLE-t ismeri. Mindezt pedig minimális overhead-del, így csak a bemeneti adatokat szükséges generálni hozzá. Mivel az alkategóriákon belül a legtöbb szabály összevonható lesz REGEX és templatelés segítségével, a sorrend sem jelent majd problémát.


Az UTLE
Tervezési szempontjai

A szakdolgozat keretében kifejlesztett nyelv a Slime nevet kapta és a továbbiakban UTLE(Universal Templater Language Extention) ként fogok rá hivatkozni. Az UTLE ugyan egy programozási nyelv, de más programozási nyelvek kiegészítésére lett kifejlesztve, és nem turing teljes. Nem gépi kódra fordul, hanem az általa kiegészített nyelvre. Erre alárendelt nyelv ként fogok hivatkozni. Gépi Kódra a generált kódot lehet fordítani a saját fordítójával. Az UTLE olyan nyelvek esetén lehet hasznos, amik nem implementáltak olyan alapvető funkciókat, mint az importálás, ciklusok, változók stb.. A behozott funkciókat a későbbiekben fogom részletezni. Az UTLE kizárólag a nyelv manipulációhoz és kód tagoláshoz hasznos funkciókra összpontosít a fejlesztés jelenlegi fázisában. Így nem tartalmaz aritmetikai műveleteket sem. Az UTLE a kívánt funkcionalitás céljából sablonokat és sablon manipulációs műveleteket használ. Eddig is sokféle template processzort és template engine-t használtak adatleíró nyelvekben az adat tömörebb leírására és könnyebb kezelésére. Például az XML és HTML kezelésére is számos templater nyelv készül. Az UTLE ezek között is egyedinek számít, mivel önálló nyelvet alkot saját fordítóval, nem pedig egy könyvtár, amit egy harmadik nyelvből kell kezelni. A többi nyelv esetén azért indokoltabb a könyvtárkénti implementáció, mert céljuk a weboldalak HTML és CSS kódjának aktív manipulációja. Az UTLE-nek más a fókusza, de semmi sem zárja ki, hogy a template manipulációs függvények és osztályok kívülről is elérhetőek legyenek. A legegyszerűbb megoldás az, ha a könyvtár kezelésére használt nyelvbe ágyazzuk az UTLE-t. Így viszont három külön fordítást kell végeznünk. A templater nyelvek többsége teljesen elkülöníti az adatot és az azt kezelő kódot, ami sok kicsi adat esetén ront az átláthatóságon és lassítja is a futást. A template adatot leíró nyelvek leggyakoribb hiányossága, hogy nem lehet bennük karaktert szöktetni. Ennek sokszor az az oka, hogy egy adott nyelv templatelésére szakosodtak (mint például a HTML). Így megtehetik, hogy olyan jelölést alkalmaznak, ami abban a nyelvben nem fordul elő (mint például a “{{ slot neve }}” ).  Így viszont a template adat leíró nyelvek sok nyelvre már nem lesznek alkalmazhatóak. A szaknyelv mester dokumentum ként hivatkoznak arra az adatra, amibe a template slotok vannak ágyazva. Mivel az UTLE nyelv független és a template kezelésével is foglalkozik, nem csak a slotok jelölésével, ezért neki a dokumentum is inkább alárendeltje.
Az UTLE a következőkre összpontosít:
alárendelt nyelvtől való függetlenség
könnyű súly és sebesség
platform függetlenség
könnyű bővíthetőség
esztétikum és felismerhetőség
kód átláthatósága és künnyen érthetősége
szabad tördelhetőség akár több fájlba
meredek tanulási görbe
hatékonyan programozás az alárendelt nyelven
A tervezés során az IRTG kiegészítése az elsődleges cél, de ezt a sok iteráció alatt kinőtte a koncepció. Az ALTO-t viszonylag könnyű kiegészíteni és módosítani, mivel kellően objektum orientált és nyílt forráskódú. Ugyanakkor az ALTO állandó fejlesztés alatt áll, ezért a forráskód módosítása és kiegészítése is verzió követést igényel. Az IRTG-nek is a legtöbb hiányossága általános és későbbi fejlesztés során pótolható. Ezek a hiányosságok  nem az IRTG belső működésének hibájára utalnak, hanem hiányosságára. Tehát módosításra nincs szükség. A program architektúrájába túl mélyen beépített elemek karbantartási költséggel járnak. Ha az ALTO pótolja a hiányosságokat, akkor teljesen feleslegesen lettek kifejlesztve a saját megoldások. Ezek a szempontok alapján lett döntve a teljesen külső megoldás mellett. Azzal, hogy az UTLE fordítója teljes mértékben független az ALTO-tól, egy olyan kiegészítést kapunk, ami jó tervezés mellett akármelyik programozási nyelv kiegészítésére jó lehet. Nem igényel verzió támogatást és az alárendelt nyelv fordítójának forrásnyelvétől függetlenül lehet akármilyen nyelven implementálva. Platform függetlenség érdekében az UTLE Kotlinban készül, és a hatékony futás érdekében később egy C++ implementációra is sor kerül. Az osztályok egyikének sem kell ALTO osztályokat hivatkoznia. Az adatstruktúrák tárolása és kezelése teljes mértékben saját kódból van megoldva jól ismert könyvtárak segítségével, így biztosítható, hogy a nyelv könnyű súlyú legyen. A nyelv szintaxisa se kellett, hogy illeszkedjen egyik nyelvhez sem. Épp ellenkezőleg. Fontos tervezési szempont volt, hogy az UTLE nyelvi elemei jól megkülönböztethetőek legyenek az alá rendelhető nyelvek többségétől. Ez persze egyszerűbb lenne a templatek és a templateket kezelő forráskód szétválasztásával, de a tervezés során fontosnak láttuk a programozói szabadságot. Az UTLE-ben van lehetőség az adat és a programkód szétválasztására, de ez nem kötelező, ami előnyös kevés kód és kisebb adatok esetén.

Alternatívák template-elésre  

Szintaxis

A legkönnyebben elválasztani különböző célú kódokat zárójelezéssel lehet. Mivel minden c alapú nyelvben a blokkok jelölésére kapcsos zárójelet használnak, az UTLE-ben is ezt logikus. A legtöbb c alapú nyelvben a zárójelet előzi meg a block típusára vonatkozó összes adat. Az UTLE ezért a differenciálás első lépéseként a zárójelek típusát a zárójelen belül jelöli. A c-ben nem véletlen van fordítva. Fontos, hogy a blokk összes meta adata elkülönüljön a blokk tartalmától. Az UTLE ezt úgy oldja meg, hogy a típusokat a nyitó zárójel után és a csukó zárójel előtt is közvetlen jelöli a lehető legnagyobb tömörséggel. Ez a tömörség a jelenlegi tervezetben típusonként és altípusonként 1-1 karaktert jelent. A zárójelben az elemeket a legtöbb nyelv vesszővel, kettősponttal és pontosvesszővel választja el, az UTLE ennek megfelelően a független elemeket vesszővel és az összefüggő elemeket kettősponttal választja el. Minden attribútum listát összefüggőnek tekintünk, amíg azok szerepe nem azonos, mint például egy lista elemeinél. Ezen kívül rengeteg nyelv jelöli hasonlóan a deklarációt, beszúrást, importálást, összeadást stb.. Az UTLE ezzel ellentétben a legalapvetőbb műveleteket is zárójelezéssel jelöli. 
Ez alapján egy blokk a nyelvben így néz ki (ahol {$  $} a slot jele): 
{{$block típus jel$}{$1.elem$}:{$2.elem$},{$3.elem$}:{$4.elem$}{$block típus jel$}}
Ez alapján egy általános struktúra típus inicializáló blokk pedig így : 
{+ {$típus neve$} : Structure : 
{$1.attribútum_neve$}:{$1.attribútum_típusa$}, 
{$2.attribútum_neve$}:{$2.attribútum_típusa$} , 
{$3.attribútum_neve$}:{$3.attribútum_típusa$},
...
+}
Ez már egy megosztó tervezési lépés volt a fejlesztés során, mivel rengeteg előnnyel és hátránnyal is jár a zárójelek halmozott használata. Hátrányos, mivel minden alap művelet is egynél több karakterrel van jelölve. A rengeteg zárójel sokak számára frusztráló lehet első nekifutásra. Ha sok azonos típusú zárójel van egymásba ágyazva, akkor nehéz átlátni, hogy melyik csukó melyik nyitóhoz tartozik. A zárójelek jelöléseinek mivel egy-két karakteresek, könnyen megkülönböztethetőnek és beszédesnek kell lennie. Egy csukó zárójel és vagy egy nyitó zárójel törlése súlyos hibákat okozhat, amik egy átláthatatlan kódban nehezen javíthatóak. Ugyanakkor egy kódot, amiben minden funkciót zárójelek és az azok által tartalmazott paraméterek jelölnek rendkívül könnyű tördelni. Minden nyitó zárójel egy új csúcs felvételét jelöli egy műveleti fában és minden csukó zárójel egy csúcsból való visszatérést a szülő csúcsba. A műveleti sorrend egyértelmű. A kód első ránézésre is megkülönböztethető bármely másik programozási nyelvtől. Az alárendelt nyelvből elég csak a speciális zárójeleket szöktetni, amire scriptet sem nehéz készíteni. Ennek következménye a könnyű tördelés és hiba érzékelés következtében a nyelv sokkal könnyedebb és így a fordítása is gyorsabb.  
A fentebb említett hátrányok kiküszöbölésére is számos megoldás lett implementálva:
Több egymást követő elemet össze lehetne vonni. Így például, ha egy sablonban sok egymást követő speciális karakterünk van “{@e@}{@t@}{@t@}”(e=enter,t=tabulátor), akkor lecserélhető erre: {@e;t;t@}. Ezzel nem csak karaktert spórolunk, hanem egy sokkal kézre esőbb karaktert használunk a ‘@’, ’{’ és ‘}’ helyett.
Az egysoros és sor végéig tart zárójelek esetén a második zárójel el is hagyható. Így például egy sor végi {@e@} helyett lehet egy “{;@e”-t használni. Igaz ekkor csak egy karaktert spórolunk, de sokkal kényelmesebb, ha a fenti módon össze vonunk több deklarációt, akkor ilyenkor a sorvégi ‘;’ is elhagyható és egy átláthatóbb kódot eredményez.
Az egy operandusú alapműveletekre be lettek vezetve egy-két karakteres jelölések. Például a templatekben a slot-ok neve mindig egy szó, így ha csak nem vonunk össze több slot-ot, akkor egy paramétere van. Ekkor használhatjuk e helyett “{$ név $}” ezt a formátumot “!$név”. Ez a formátum az első whitespace-ig tart.
Ezek mellett be lehet vezetni egy feltűnő zárójelet is, ami nem tartalmaz alárendelt nyelvi kódot, ezért minden művelet jelölhető benne tömörebben. A zárójeleknek be lehet vezetni opcionális azonosítókat, ami a HTML-hez és XML-hez hasonlóan összepárosítja a blokk nyitó és csukó jeleket. Így könnyű az azonos típusú zárójeleket is megkülönböztetni, sőt sokkal beszédesebb hibaüzenetet lehet dobni, ha a nyitó vagy a csukó zárójel hiányzik. Ezekről a tervezett fejlesztésekről többet írok még a … fejezetben.
A nyelv sajátossága szintén, hogy nem a kódba van ágyazva az adat, hanem az adatba van ágyazva a kód. Tehát minden, ami műveleti zárójelen kívül van, az egy az egyben fog szerepelni a generált kimenetben. Így a programozó döntheti el, hogy az UTLE-re támaszkodik elsődlegesen vagy az alárendelt nyelvre, amit csak apró dolgokban egészít ki az UTLE-ben. A fordító közvetlen a speciális zárójelek(beleértve a meta adatot is) előtt és mögött minden backspace karaktert szöktet a második enterig, hogy a szöveget könnyű legyen tagolni.
A gyors futás érdekében az architektúra letisztult. A változók egyetlen egy Map-ben tárolódnak el. A változók és tagváltozóik egy fa szerkezetet alkotnak. Az egy fájlban tárolt változók a fájl nevével ellátott csúcson keresztül érhetőek el. Más fájlnak is elérjük az adatait, ha importáltuk. Ekkor a fájl olyan, mint egy változó. Egy változó tagváltozói a megszokott ponttal érhetőek el. Ezen kívül minden változónak adhatóak szinonimák is, amikkel ugyanúgy meghivatkozható. A szinonimák azon a fájlon keresztül érhetőek el, ahol deklarálva lettek a változó helyétől függetlenül. Egy fájlon belül természetesen nem kell megadni magának a fájlnak a nevét is minden ott deklarált változó és szinoníma előtt. Így a szerkezet egy fa, ahol a csúcsok maguk a változók. Minden változó dinamikusan tárolódik. Egy változó csak az eredeti nevével törölhető, egy szinoníma törlésénél csak a szinonima törlődik. Egy változó törlésénél a tagváltozók is törlődnek minden szinonimájukkal együtt. Jelenleg még minden változót manuálisan kell törölni, ha a UTLE kód lefutása előtt szeretnénk felszabadítani. Erre szükség is van, ha nagy adathalmazból generáltunk kódot. 
Jelenleg UTLE-ben a template(sablon), slot(hely), special character(speciális karakter), synonym(szinonima), regex, list(lista), structure(struktúra) és structure instance(struktúra példány) típusok léteznek. A template maga a szöveg. Tartalmazhat slotokat, special character-öket és synonym-okat. A slot az a template-n belül azokat a névvel ellátott helyeket jelöli, ahova más templateket lehet beszúrni. A slotok szinonimákat tárolnak és a beléjük szúrt templatet, ha létezik ilyen. A beszúrt template minden slot-ját is a slot tagváltozója ként lehet elérni, mivel a beszúrt templat-nek csak a másolata szúródik bele, ami így nem rendelkezik névvel. Tehát beszúrásnál a slot nem tűnik el.  A special character a backspace karaktereket jelöli, mivel a zárójeleken belül a legtöbb helyen a backspace karakterek szöktetve vannak. A synonym eggyel feljebb már taglalva van. Nem több mint egy hivatkozás az egyik változóra. Ha lekérjük a fából, akkor maga helyett az általa hivatkozott változót téríti vissza. Mivel maga is változó, neki is lehet neve és neki is lehetnek synonym-jai. Mikor lekérünk egy synonym-ot a fából, ami egy synonym-ot hivatkozik, akkor az maga helyett a másik synonymot küldi vissza, ami ekkor maga helyett az általa hivatkozott synonym-át. A regex az a változó, ami az egyik legfőbb funkcionalitást valósítja meg. A regex is egy hivatkozás, de lekérésekor a nevére illeszkedő változókat téríti vissza list-be szervezve. A list mint minden nyelvben, egy elem tároló, ami adott típusú változókból képes akármennyit eltárolni. Egy változó synonym-jai és egy template slot-jai is listában rendeződnek, mikor lekérdezik őket. Egy lista indexelhető, de végig iterálni csak elemenként lehet aritmetikai műveletek híján. A structure egy olyan változó, ami típus név párokat tárol és példányosítható structure instance-ként.
Mindez a lehető legobjektumorientáltabban van megvalósítva. Minden változó típus külön osztály, és a fa tároló egy külön gráf. A tördelt szöveg egy műveleti erdővé fordul, ami fentről lefelé szekvenciálisan hajtódik végre. Magát a tördelést kotlinban az ANTLR segítségével valósítottam meg.

Alapműveletek és változók
Konkrét megoldásaink
A fejlesztés fázisai
Fejlett megoldásaink

Az UTLE-ben az operátorokat, a típusokat és fordítási beállításokat is speciális zárójelek jelölik és a nyelv kapcsán marker(jelölő) ként vannak hivatkozva. Ezeket a jelölőket ennek megfelelően három csoportba soroljuk. Léteznek Type Marker-ek, amik a primitív típusokat jelölik, Operater Marker-ek, amik az egyes template manipulációs és egyéb műveleteket jelölik, és Compilation Mode Markerek

