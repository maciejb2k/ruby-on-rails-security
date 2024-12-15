# Mass Assignment

## Description

Mass assignment is a mechanism in Ruby on Rails that allows assigning multiple parameters to a model at once, such as when creating a new record or updating an existing one. By default, Rails protects applications from unwanted parameter assignments, but improper configuration can lead to security vulnerabilities.

## Vulnerability Example

This application demonstrates two user models:
- `InsecureUser` - a model vulnerable to mass assignment attacks.
- `SecureUser` - a model protected against mass assignment attacks.

### Step 1: Run the Application and Verify the Vulnerability

After starting the application, go to the following address:

http://localhost:3000/insecure_users

![Insecure Users](./screenshots/insecure-users.png)

You will see a list of users. Then, open the page for the first user:

http://localhost:3000/insecure_users/1

![Insecure User](./screenshots/show-insecure-user.png)

On the user's detail page, you will see that the `admin` attribute is set to `false`.

### Step 2: Attempt to Modify a Hidden Attribute

On the edit page for this user, you will not find a field to edit the `admin` attribute. However, a potential attacker could guess its existence and attempt to modify it by directly sending an HTTP request.

![Edit Insecure User](./screenshots/edit-insecure-user.png)

An HTTP request to change the `admin` value is prepared in the `requests.http` file.

![Edit Insecure User Request](./screenshots/update-insecure.png)

Execute it using an API testing tool, such as the **REST Client** plugin in **Visual Studio Code**, by clicking the "Send Request" button.

### Step 3: Check the Result

After sending the request, you will receive a `200 OK` response. Open the user page again:

http://localhost:3000/insecure_users/1

![Insecure User Updated](./screenshots/show-updated-insecure.png)

You will see that the `admin` attribute has been changed to `true`, confirming the vulnerability in the `InsecureUser` model.

This vulnerability arises because the `InsecureUser` model allows any parameters to be assigned, including hidden attributes, which poses a security risk for the application.

As seen in the `app/controllers/insecure_users_controller.rb` file, all parameters are assigned without restrictions (this also applies to the `create` action):

```ruby
# PATCH/PUT /insecure_users/1
def update
  if @insecure_user.update(params[:insecure_user])
    redirect_to @insecure_user, notice: 'Insecure user was successfully updated.', status: :see_other
  else
    render :edit, status: :unprocessable_entity
  end
end
```

## Recommendations

Ruby on Rails provides default protection against mass assignment attacks by enforcing the use of strong parameters in controllers. This allows developers to explicitly specify which attributes can be assigned during record creation or updates.

### Strong Parameters

If you try to assign attributes to a model without explicitly defining them in strong parameters, Rails will raise an error:
`ActiveModel::ForbiddenAttributesError`.

In this application, the default protection was deliberately disabled by modifying the configuration in the `config/application.rb` file:

```ruby
config.action_controller.permit_all_parameters = true
```

In real applications, this mechanism should not be disabled, or it should be set to `false`.

### Example of Proper Protection

For the `SecureUser` model, strong parameters are implemented in the controller, ensuring that only specific attributes, such as `name` and `email`, can be assigned. The `admin` attribute is excluded from the list of permitted parameters:

```ruby
# PATCH/PUT /secure_users/1
def update
  if @secure_user.update(secure_user_params)
    redirect_to @secure_user, notice: 'Secure user was successfully updated.', status: :see_other
  else
    render :edit, status: :unprocessable_entity
  end
end

...

private

def secure_user_params
  params.require(:secure_user).permit(:name, :email)
end
```

### Verifying the Security Measures

After sending an HTTP request for the `SecureUser` model, the application will return a `200 OK` response.

![Secure User Updated](./screenshots/show-secure.png)

![Edit Secure User Request](./screenshots/update-secure.png)

However, the `admin` attribute will not be changed because it is not permitted in the strong parameters.

![Secure User Updated](./screenshots/show-updated-secure.png)
