Shawn Brown

p2

CS4280

BNF: 
<program>  ->     start <vars> main <block> stop
<block>       ->      { <vars> <stats> }
<vars>         ->      empty | let Identifier :  Integer    <vars>
<expr>        ->      <N> / <expr>  | <N> * <expr> | <N>
<N>             ->       <A> + <N> | <A> - <N> | <A>
<A>              ->     % <A> |  <R>
<R>              ->      [ <expr> ] | Identifier | Integer
<stats>         ->      <stat>  <mStat>
<mStat>       ->      empty |  <stat>  <mStat>
<stat>           ->      <in> .  | <out> .  | <block> | <if> .  | <loop> .  | <assign> .  
<in>              ->      scanf [ Identifier ]
<out>            ->      printf [ <expr> ]
<if>               ->      if [ <expr> <RO> <expr> ] then <block>
<loop>          ->      iter [ <expr> <RO> <expr> ]  <block>
<assign>       ->      Identifier  = <expr> 
<RO>            ->      =<  | =>   |  ==  |   :  :  (two tokens)
