# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     InvoiceApp.Repo.insert!(%InvoiceApp.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Faker.Address
alias Faker.Internet
alias Faker.Lorem
alias Faker.Person
alias Faker.Phone.PtPt
alias InvoiceApp.Accounts.BusinessAddress
alias InvoiceApp.Accounts.EmailPreferences
alias InvoiceApp.Accounts.User
alias InvoiceApp.Invoices.BillFrom
alias InvoiceApp.Invoices.BillTo
alias InvoiceApp.Invoices.Invoice
alias InvoiceApp.Invoices.Item
alias InvoiceApp.Repo

## Create Users
credentials = [
  {"test1@email.com", "TVZ0myr_wcj4zmu7njq"},
  {"test2@email.com", "NTtt9HYNM@*kv2sEdHzF"},
  {"test3@email.com", "bLhYFVk@F.T8BvXTGyHK"}
]

users =
  for {email, password} <- credentials do
    %User{
      full_name: Person.name(),
      username: Internet.user_name(),
      email: email,
      hashed_password: Bcrypt.hash_pwd_salt(password),
      business_address: %BusinessAddress{
        country: Address.country_code(),
        city: Address.city(),
        street_address: Address.street_address(),
        postal_code: Address.postcode(),
        phone_number: PtPt.landline_number()
      },
      email_preferences: %EmailPreferences{},
      avatar_url: "/images/default_avatar.png",
      confirmed_at:
        NaiveDateTime.utc_now()
        |> NaiveDateTime.truncate(:second)
    }
    |> Repo.insert!()
  end

## Create 10 invoices for each user
Enum.each(users, fn user ->
  for _ <- 1..10 do
    %Invoice{
      bill_from: %BillFrom{
        city: Address.city(),
        country: Address.country_code(),
        post_code: Address.postcode(),
        street_address: Address.street_address()
      },
      bill_to: %BillTo{
        city: Address.city(),
        name: Person.name(),
        country: Address.country_code(),
        email: Internet.email(),
        post_code: Address.postcode(),
        street_address: Address.street_address()
      },
      items:
        Enum.map(1..5, fn _ ->
          %Item{
            name: Faker.Lorem.word(),
            price: Enum.random(1..1_000),
            quantity: Enum.random(1..5),
            total: Enum.random(1..10_000)
          }
        end),
      date: Date.utc_today(),
      status: Enum.random([:paid, :pending, :draft]),
      payment_term: Enum.random([1, 7, 14, 30]),
      project_description: Lorem.paragraph(1),
      user_id: user.id
    }
    |> Repo.insert!()
  end
end)
