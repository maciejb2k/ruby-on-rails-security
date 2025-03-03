// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails";
import "controllers";
// app/javascript/application.js

Turbo.setFormMode("off");

// for turbo v8.0.6+
Turbo.config.forms.mode = "off";
