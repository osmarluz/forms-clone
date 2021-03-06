# Forms Clone
> This is the repository for an API developed using Ruby on Rails that implements the CRUD operations for a Google Forms clone application. 

![ruby](https://img.shields.io/badge/Ruby-2.3.5-red.svg)
![rails](https://img.shields.io/badge/Rails-5.0.6-red.svg)

## Development Setup

### 1. Build the containers

`docker-compose build`

### 2. Create the database on the container

`docker-compose run --rm website bundle exec rails db:create`

### 3. Run the database migrations on the container

`docker-compose run --rm website bundle exec rails db:migrate`

### 4. Start the containers

`docker-compose up`

## Meta

Osmar Luz – osmar.luz@gmail.com

[https://github.com/osmarluz](https://github.com/osmarluz/)

## Contributing

1. Fork it (<https://github.com/osmarluz/forms-clone>)
2. Create your feature branch (`git checkout -b feature/fooBar`)
3. Commit your changes (`git commit -m 'Add some fooBar'`)
4. Push to the branch (`git push origin feature/fooBar`)
5. Create a new Pull Request