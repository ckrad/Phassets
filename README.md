Phassets
==============
**Phassets** is an effort to make PHP projects less painful by adding an asset pipeline powered by pure [Sprockets][91] magic. It's on an early stage and is not intended to use in production (yet).



Requirements
-----------------
* Ruby 2.0.0+
* Java Runtime

**Windows users:** You might want to install [node.js][92] to dramatically speed up the javascript compilation (and restart your PC afterwards)



Installation
-----------------

1) Clone this repository (or copy the `Phassets` directory) to the root of your project.

```
Project/
  |- assets/
  |   |- images/
  |   |- javascripts/
  |       |- application.js
  |   |- stylesheets/
  |       |- application.scss
  |- Phassets/
  |- index.php
```

2) Edit `Phassets/config/settings.json` with your project information. Please make sure to use a relative path for the **assets_path** (from project root).

3) Require the `Phassets/lib/phassets.php` class and add the helpers:

```
<? require_once 'Phassets/lib/phassets.php'; ?>
<!DOCTYPE html>
<html>
  <head>
    <?= Phassets::styles(); ?>
  </head>
  <body>
    <?= Phassets::scripts(); ?>
  </body>
</html>
```

4) Change directory to `Phassets` and run `bundle install`.



Start the Server
-----------------

Once the script is configured you can start the server by running `rackup` inside the `Phassets` directory.



Manifest Files
-----------------

By default **Phassets** works with the following manifest files:

####application.js

Located at | Compiles to:
:--------: | :----------:
**assets_path**/javascripts/application.js | **assets_path**/application.js

####application.css

Located at | Compiles to:
:--------: | :----------:
**assets_path**/stylesheets/application.scss | **assets_path**/application.css

You can override this by changing the **js_manifests** and **css_manifests** arrays in the `Phassets/config/settings.json` file. Don't forget to also request the new manifest files using the PHP helpers (See below).

Please note that for your stylesheets you can use either CSS or SASS, so change the file extension accordingly but make sure to always use `.css ` when referencing it within the code.



Compilation
-----------------
Your assets can be compiled using the following rake tasks:

* `rake assets:compile`
* `rake assets:compile_js`
* `rake assets:compile_css`

**Important!** Only the manifest files listed in the **js_manifests** and **css_manifests** arrays in the `Phassets/config/settings.json` file will be compiled.



####Compressors:

* **Uglifier** for Javascript
* **YUI Compressor** for CSS


Environments
-----------------

Each environment is defined by a **JSON** file inside `Phassets/config/environments/`, **Phassets** comes by default with 2 environments **development** and **production** but you can have as many as you want. If you plan to add more please make sure to use lowercased names without spaces nor special characters.

Also make sure your **production** environments have the **static_assets** set to **true** so the assets are served by your web server instead of the Phassets rack server.


#### Environment Selection

In the current version of **Phassets** the environment selection comes in 3 flavours:

**1. Default Environment:** The **default_environment** is defined in the `Phassets/config/settings.json`. The default environment setting is available to both Ruby and PHP and will be used if the other methods fail.

**2. Local Environment:** You can set your local environment by running `rake environment` inside the `Phassets` directory, this will generate the `Phassets/support/local_environment` file for you. The local environment setting is available to both Ruby and PHP and is the preferred way to set your environment just make sure to ignore it so you don't bother other developers.

**3. PHP Environment:** By defining the **PH_ENV** constant in PHP you can override the previous methods but as you can imagine this only works for PHP. This is a handy way to use in production since It will simplify the selection resulting in a much faster execution.

```
define( 'PH_ENV', 'production' );
require_once 'Phassets/lib/phassets.php';
```



Helpers
-----------------

**Phassets** provides 2 helpers similar to Rail's `stylesheet_link_tag` and `javascript_include_tag` that you can place within your HTML to will yield the script and link tags:

* ``Phassets::styles()``
* ``Phassets::scripts()``

**Important!** Only the manifest files listed in the **js_manifests** and **css_manifests** arrays in the `Phassets/config/settings.json` file will be compiled.

####Behavior:

1. If **no parameter** is given the helpers will request the manifest files specified in the `Phassets/config/settings.json` file.
2. If a **string** is given only a single file will be requested.
3. If an **array** is given multiple files can be requested.



Images
-----------------

Images should be located at `assets/images` and It's possible to use sub-directories. They can be linked within **scss** files by using the helper method `asset-path` with the image name or relative path to `assets/images` as the paramether.

####Examples:

* `background-image: url(asset-path("dog.jpg"))`
* `background-image: url(asset-path("icons/home.png"))` 

**Note:** Other helpers will be added in a near future for other kind of assets.



Pushing to Production
-----------------

The **Phassets** directory contains an **.htaccess** file that denies all requests so you can safely push it to your production server.

In case you want to upload the minimum amount of files for this script to work this is wath you should include for a project running in production mode:

```
Phassets/
  |- lib/
  |   |- phassets.php
  |- config/
  |   |- environments/
  |   |   |- production.json
  |   |- settings.json
  |- support/
  |   |- digests.json
  |- .htaccess
```

**Note:** If you upload it manually (FTP/SFTP) please make sure to update or remove the `Phassets/support/local_environment` file first. If you deploy via Git you can ignore that file and forget about it.



Credits
-----------------

* [Sprockets][91] by [Sam Stephenson][101] and [Joshua Peek][102]



License
-----------------
**Phassets** is released under the [MIT license][50].



Author
-----------------

* [Mariano Cavallo][100] ([Indicius][90])

[50]: LICENSE
[90]: http://indicius.com
[91]: https://github.com/sstephenson/sprockets
[92]: http://nodejs.org/
[100]: https://github.com/mcavallo
[101]: https://github.com/sstephenson
[102]: https://github.com/josh
