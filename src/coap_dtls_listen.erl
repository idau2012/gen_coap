%%--------------------------------------------------------------------
%% Copyright (c) 2020 EMQ Technologies Co., Ltd. All Rights Reserved.
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.
%%--------------------------------------------------------------------

-module(coap_dtls_listen).

-author("dwg <dwg@emqx.io>").


-behaviour(gen_server).

%% API
-export([start_link/3]).

%% gen_server callbacks
-export([init/1,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         terminate/2,
         code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {lsock}).

%%%===================================================================
%%% API
%%%===================================================================
start_link(SocketSup, InPort, Opts) ->
    gen_server:start_link(?MODULE, [SocketSup,InPort, Opts], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

init([SocketSup, InPort, Opts]) ->
    process_flag(trap_exit, true),
    case ssl:listen(InPort, Opts) of
        {ok, ListenSocket} ->
            [{ok , _} = coap_dtls_socket_sup:start_socket(SocketSup, ListenSocket) || _ <- lists:seq(1,20)],
            {ok, #state{lsock = ListenSocket}};
        {error, Reason} ->
            {stop, {cannot_listen, InPort, Reason}}
    end.

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, #state{lsock = LSock}) ->
    ssl:close(LSock),
    ok.

code_change(_OldVsn, State, _Extra) ->
        {ok, State}.

% end of file
