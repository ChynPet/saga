defmodule Sagas.Email.SignUp do

  def start_link do
    :gen_fsm.start_link({:local, __MODULE__}, __MODULE__, [], [])
  end


  def init(start) do
    :erlang.process_flag(:trap_exit, true)
    {:ok, :sign_up, start}
  end

  #Event
  def send_email(user), do: :gen_fsm.send_event(__MODULE__, {:send_email, user})
  def email_add(user), do: :gen_fsm.send_event(__MODULE__, {:email_add, user})
  def confirm_email(user), do: :gen_fsm.send_event(__MODULE__, {:confirm_email, user})
  def email_confirmed(user), do: :gen_fsm.send_event(__MODULE__, {:email_confirmed, user})
  def send_token(user), do: :gen_fsm.send_event(__MODULE__, {:send_token, user})
  def stop(), do: :gen_fsm.sync_send_all_state_event(__MODULE__, {:stop})

  #State
  def sign_up({:send_email, user}, _loop_data) do
    {:next_state, :sending_email, user}
  end

  def sending_email({:email_add, user}, _loop_data) do
    {:next_state, :email_added, user}
  end

  def email_added({:confirm_email, user}, _loop_data) do
    {:next_state, :confirming_email, user}
  end

  def confirming_email({:email_confirmed, user}, _loop_data) do
    {:next_state, :confirmed_email, user}
  end

  def confirmed_email({:send_token, user}, user) do
    {:next_state, :stop, user}
  end

  def handle_sync_event({:stop}, _from, _state, _loop_date) do
    {:stop, :normal, []}
  end

  def terminate(_reason, _statem_name, _loop_data) do
    :ok
  end
end
