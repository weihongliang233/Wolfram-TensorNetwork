(* ::Package:: *)

(* Author:XiaMing Zheng, Hongliang Wei *)

BeginPackage["TensorNetwork`"]


NetworkContract::usage="Please refer to this website:https://www.tensors.net/code, this function is correspond to 'ncon' in the website."


Begin["`Private`"]


NetworkContract[tensorlistin_List,connectlistin_List,contractorderin_List:{},finalorderin_List:{},checknetwork_:True]:=Module[{tensorlist,connectlist,contractorder,finalorder,(*check inputs if enabled*)flatconnect,dimensionlist,(*do all partial traces*)completepartialtracetable,computedpartialtracetable,traceresult,(*do all binary contractions*)contractingindices,contractlocation,tensoraindices,tensorbindices,countmany,acont,bcont,af,bf,(*do all tensorproducts*)transposepara},
(*generate contraction order if necessary*)
tensorlist=tensorlistin;connectlist=connectlistin;contractorder=contractorderin;finalorder=finalorderin;
flatconnect=Flatten[connectlist];
If[contractorder=={},contractorder=Sort[DeleteDuplicates[Cases[flatconnect,_?Positive]]];];
(*check inputs if enabled*)
If[checknetwork,dimensionlist=Map[Dimensions,tensorlist];NconInputCheck[connectlist,flatconnect,dimensionlist,contractorder]];
(*do all partial traces*)
completepartialtracetable=Partition[Riffle[tensorlist,connectlist],2];
computedpartialtracetable=Map[TensorPartialTrace@@#&,completepartialtracetable];
traceresult=Transpose[computedpartialtracetable,{2,1}];{tensorlist,connectlist}=Part[traceresult,{1,2}];contractorder=DeleteCases[contractorder,Alternatives@@Flatten[traceresult[[3]]]];
(*do all binary contractions*)
While[contractorder!={},contractingindices=contractorder[[1]];contractlocation=Position[connectlist,contractingindices];tensoraindices=Part[connectlist,Part[contractlocation,1,1]];tensorbindices=Part[connectlist,Part[contractlocation,2,1]];countmany=Intersection[tensoraindices,tensorbindices];
acont=Flatten[Map[Position[tensoraindices,#]&,countmany]];bcont=Flatten[Map[Position[tensorbindices,#]&,countmany]];af=Delete[tensoraindices,Partition[acont,1]];bf=Delete[tensorbindices,Partition[bcont,1]];
AppendTo[tensorlist,TensorDotProduct[Part[tensorlist,Part[contractlocation,1,1]],Part[tensorlist,Part[contractlocation,2,1]],acont,bcont]];AppendTo[connectlist,Join[af,bf]];
tensorlist=Delete[tensorlist,Partition[Part[contractlocation,All,1],1]];connectlist=Delete[connectlist,Partition[Part[contractlocation,All,1],1]];
contractorder=DeleteCases[contractorder,Alternatives@@countmany];
];
(*do all tensorproducts*)
If[Length[tensorlist]>1,tensorlist={TensorProduct@@tensorlist};connectlist={Flatten[connectlist]};];
(*do final permutation*)
If[Length[connectlist[[1]]]>0,If[finalorder=={},finalorder=Cases[flatconnect,_?Negative];transposepara=Flatten[Position[finalorder,#]&/@connectlist[[1]]];Return[Transpose[tensorlist[[1]],transposepara]],transposepara=Flatten[Position[finalorder,#]&/@connectlist[[1]]];Return[Transpose[tensorlist[[1]],transposepara]]],Return[tensorlist[[1]]]]
]
TensorReorder[tensor_List,indices_List]:=Module[{tensorindices,processindices},tensorindices=Range[TensorRank[tensor]];processindices=Flatten[Position[indices,#]&/@tensorindices];Transpose[tensor,processindices]]
TensorDotProduct[a_List,b_List,acontract_List,bcontract_List]:=
Module[{afree,bfree,apermutation,bpermutation,newt},afree=DeleteCases[Range[TensorRank[a]],Alternatives@@Sort[acontract]];bfree=DeleteCases[Range[TensorRank[b]],Alternatives@@Sort[bcontract]];apermutation=Join[afree,acontract];bpermutation=Join[bcontract,bfree];newt=ArrayReshape[(ArrayReshape[TensorReorder[a,apermutation],{Times@@(Part[Dimensions[a],afree]),Times@@(Part[Dimensions[a],acontract])}] . ArrayReshape[TensorReorder[b,bpermutation],{Times@@(Part[Dimensions[b],bcontract]),Times@@(Part[Dimensions[b],bfree])}]),Join[Part[Dimensions[a],afree],Part[Dimensions[b],bfree]]];newt
]
TensorPartialTrace[tensor_List,indices_List]:=Module[{unduplicatedindices,contractindices,contractposition,newt,newi},
unduplicatedindices=DeleteDuplicates[indices];If[Length[indices]-Length[unduplicatedindices]>0,
contractindices=Select[unduplicatedindices,Count[indices,#]>1&];contractposition=Select[Flatten[Position[indices,#]]&/@contractindices,Length[#]!=1&];
newt=TensorContract[tensor,contractposition];newi=DeleteCases[unduplicatedindices,Alternatives@@contractindices];Flatten[{newt,newi,contractindices},{1}],Flatten[{tensor,indices,{}},{1}]]]
NconInputCheck[connectlist_List,flatconnect_List,dimensionlist_List,contractorder_List]:=Module[{positiveindices,negativeindices,
(*check that lengths of lists match*)dimensionlistlength,connectlistlength,
(*check that tensors have the right number of indices*)dimensionlistlengthtable,connectlistlengthtable,dimensionconnectdismatchtable,
(*check that indices are valid*)unduplicatednegative,unduplicatedpositive,negativeindicesnumber,positiveindicesnumber,standnegativeindicestimes,standpositiveindicestimes,countsnegativeindices,countspositiveindices,wrongnegativeindices,wrongpositiveindices,contractposition,dimensionmatch,wrongpositivedimensionpositions},
positiveindices=Cases[flatconnect,_?Positive];negativeindices=Cases[flatconnect,_?Negative];
Off[General::partw];Off[Part::partd];
(*check that lengths of lists match*)
dimensionlistlength=Length[dimensionlist];
connectlistlength=Length[connectlist];
If[dimensionlistlength!=connectlistlength,NetworkContract::len1=StringJoin [{ToString[dimensionlistlength]," tensors given, but ",ToString[connectlistlength]," index sublists given"}];Message[NetworkContract::len1];];
(*check that tensors have the right number of indices*)
dimensionlistlengthtable=Map[Length,dimensionlist];connectlistlengthtable=Map[Length,connectlist];
If[dimensionlistlengthtable!=connectlistlengthtable,dimensionconnectdismatchtable=Flatten[Position[Map[Part[dimensionlistlengthtable,#]==Part[connectlistlengthtable,#]&,Range[Length[connectlistlengthtable]]],False]];NetworkContract::len2=StringJoin["No.",Riffle[ToString/@dimensionconnectdismatchtable,","]," tensors do not match their numbers of labels"];Message[NetworkContract::len2]];
(*check that contraction order is valid*)
If[!(Sort[contractorder]==Sort[DeleteDuplicates[positiveindices]]),NetworkContract::len3="invalid contraction order";Message[NetworkContract::len3]];(*check that negative indices are valid*)
unduplicatednegative=DeleteDuplicates[negativeindices];negativeindicesnumber=Length[unduplicatednegative];standnegativeindicestimes=ConstantArray[1,negativeindicesnumber];If[Complement[unduplicatednegative,Range[-1,-negativeindicesnumber,-1]]!={},NetworkContract::len41="negative indices names greater than indices number";Message[NetworkContract::len41],If[countsnegativeindices=Normal[Counts[negativeindices]];countsnegativeindices[[All,2]]!=standnegativeindicestimes,wrongnegativeindices=Select[countsnegativeindices,#[[2]]!=1&][[All,1]];NetworkContract::len42=StringJoin["negative indices ",Riffle[ToString/@wrongnegativeindices,","]," appear more than once"];Message[NetworkContract::len42]]];
(*check that positive indices are valid and contracted tensor dimensions match*)
unduplicatedpositive=DeleteDuplicates[positiveindices];positiveindicesnumber=Length[unduplicatedpositive];standpositiveindicestimes=ConstantArray[2,positiveindicesnumber];
If[Complement[unduplicatedpositive,Range[positiveindicesnumber]]!={},NetworkContract::len51="positive indices names greater than indices number";Message[NetworkContract::len51],If[countspositiveindices=Normal[Counts[positiveindices]];countspositiveindices[[All,2]]!=standpositiveindicestimes,wrongpositiveindices=Select[countspositiveindices,#[[2]]!=2&][[All,1]];NetworkContract::len52=StringJoin["positive indices ",Riffle[ToString/@wrongpositiveindices,","]," do not appear twice"];Message[NetworkContract::len52],If[contractposition=Select[Position[connectlist,#]&/@unduplicatedpositive,Length[#]==2&];dimensionmatch=Boole[Map[Equal@@#&,(Extract[dimensionlist,#])&/@contractposition]];dimensionmatch!=standpositiveindicestimes/2,wrongpositivedimensionpositions=Flatten[Position[dimensionmatch,0]];NetworkContract::len53=StringJoin["contracted dimension of ","positive indices ",Riffle[ToString/@Part[unduplicatedpositive,wrongpositivedimensionpositions],","]," are unmatched"];Message[NetworkContract::len53]]]];On[General::partw];Off[Part::partd];

]


End[]


EndPackage[]
