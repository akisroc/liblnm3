# defmodule PlatformInfra.Accounts.SessionTest do
#   use Platform.DataCase, async: true

#   alias Platform.Accounts.Session
#   alias P
#   import Platform.Fixtures

#   describe "generate_session_token/3" do
#     setup do
#       user = user_fixture()
#       {:ok, user: user}
#     end

#     test "generates a token and creates session", %{user: user} do
#       token = Session.generate_session_token(user, "127.0.0.1", "Test Browser")

#       assert is_binary(token)
#       assert byte_size(token) == 32

#       # Verify session was created
#       session = Repo.get_by(Session, user_id: user.id)
#       assert session != nil
#       assert session.context == "session"
#       assert session.user_agent == "Test Browser"
#     end

#     test "stores hashed token in database", %{user: user} do
#       token_bytes = Session.generate_session_token(user, "127.0.0.1", "Browser")

#       session = Repo.get_by(Session, user_id: user.id)

#       # Token in DB should be SHA256 hash of the raw bytes
#       expected_hash = :crypto.hash(:sha256, token_bytes)
#       assert session.token == expected_hash
#     end

#     test "sets expiration date", %{user: user} do
#       Session.generate_session_token(user, "127.0.0.1", "Browser")

#       session = Repo.get_by(Session, user_id: user.id)

#       # Should expire in 120 days
#       # expected_expiry = DateTime.add(DateTime.utc_now(), Session.session_validity_in_seconds(), :second)
#       # diff = DateTime.diff(session.expires_at, expected_expiry)

#       # Allow 2 seconds tolerance
#       assert abs(diff) <= 2
#     end

#     test "stores IP address", %{user: user} do
#       Session.generate_session_token(user, "192.168.1.1", "Browser")

#       session = Repo.get_by(Session, user_id: user.id)
#       assert session.ip_address != nil
#     end
#   end

#   describe "get_user_by_session_token/1" do
#     setup do
#       user = user_fixture()
#       token_bytes = Session.generate_session_token(user, "127.0.0.1", "Browser")
#       token_encoded = Base.url_encode64(token_bytes, padding: false)

#       {:ok, user: user, token: token_encoded}
#     end

#     test "retrieves user with valid token", %{user: user, token: token} do
#       assert {:ok, retrieved_user} = Session.get_user_by_session_token(token)
#       assert retrieved_user.id == user.id
#     end

#     test "returns error with invalid token" do
#       assert {:error, :invalid_encoding} = Session.get_user_by_session_token("invalid")
#     end

#     test "returns error with non-existent token" do
#       fake_token = Base.url_encode64(:crypto.strong_rand_bytes(32), padding: false)
#       assert {:error, :not_found} = Session.get_user_by_session_token(fake_token)
#     end

#     test "returns error for expired token", %{user: user} do
#       # Create session with past expiration
#       token_bytes = :crypto.strong_rand_bytes(32)
#       hashed_token = :crypto.hash(:sha256, token_bytes)
#       {:ok, inet_addr} = :inet.parse_address(~c"127.0.0.1")

#       Repo.insert!(%Session{
#         user_id: user.id,
#         token: hashed_token,
#         context: "session",
#         ip_address: %Postgrex.INET{address: inet_addr},
#         user_agent: "Browser",
#         expires_at: DateTime.add(DateTime.utc_now(), -1, :day)
#       })

#       token_encoded = Base.url_encode64(token_bytes, padding: false)
#       assert {:error, :not_found} = Session.get_user_by_session_token(token_encoded)
#     end
#   end

#   describe "delete_expired_sessions/0" do
#     test "deletes expired sessions" do
#       user = user_fixture()
#       {:ok, inet_addr} = :inet.parse_address(~c"127.0.0.1")

#       # Create expired session
#       Repo.insert!(%Session{
#         user_id: user.id,
#         token: :crypto.hash(:sha256, :crypto.strong_rand_bytes(32)),
#         context: "session",
#         ip_address: %Postgrex.INET{address: inet_addr},
#         user_agent: "Browser",
#         expires_at: DateTime.add(DateTime.utc_now(), -1, :day)
#       })

#       # Create valid session
#       Session.generate_session_token(user, "127.0.0.1", "Browser")

#       assert Repo.aggregate(Session, :count) == 2

#       assert {:ok, 1} = Session.delete_expired_sessions()
#       assert Repo.aggregate(Session, :count) == 1

#       # Remaining session should be the non-expired one
#       # [session] = Repo.all(Session)
#       # assert DateTime.compare(session.expires_at, DateTime.utc_now()) == :gt
#     end

#     test "returns zero when no expired sessions" do
#       user = user_fixture()
#       Session.generate_session_token(user, "127.0.0.1", "Browser")

#       assert {:ok, 0} = Session.delete_expired_sessions()
#       assert Repo.aggregate(Session, :count) == 1
#     end
#   end
# end
