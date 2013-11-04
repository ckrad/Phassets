<?

if ( !defined('PH_BASE') )
  define('PH_BASE', realpath(dirname(__FILE__) . DIRECTORY_SEPARATOR . '..'));

class Phassets
{
  protected static $instance  = null;
  protected static $config    = null;
  protected static $digests   = null;

  function __construct(){}
  function __clone(){}

  public static function get_instance()
  {
    if ( !isset(static::$instance) )
      static::$instance = new static;

    return static::$instance;
  }

  public function configure()
  {
    $config = $this->load_json_file(join(DIRECTORY_SEPARATOR, array(PH_BASE, 'config', 'settings.json')));

    if ( !defined('PH_ENV') )
    {
      $environment = $this->read_local_environment();
      if ( !$environment )
        $environment = $config['default_environment'];
    }
    else
    {
      $environment = PH_ENV;
    }

    $env_config = $this->load_json_file(join(DIRECTORY_SEPARATOR, array(PH_BASE, 'config', 'environments', "{$environment}.json")));

    if ( $env_config['static_assets'] )
      $this->load_digests();

    static::$config = array_merge($config, $env_config);
  }

  public function load_digests()
  {
    static::$digests = $this->load_json_file(join(DIRECTORY_SEPARATOR, array(PH_BASE, 'support', 'digests.json')));
  }

  public static function styles( $requested_files=null )
  {
    $am = self::get_instance();
    $am->render_links( 'css', $requested_files );
  }

  public static function scripts( $requested_files=null )
  {
    $am = self::get_instance();
    $am->render_links( 'js', $requested_files );
  }

  protected function render_links( $type, $requested_files=null )
  {
    $files    = array();
    $base_url = $this->assets_url();

    if ( is_string($requested_files) )
      $requested_files = array( $requested_files );

    if ( !$requested_files )
      $requested_files = (array)static::$config[$type.'_manifests'];

    switch ( $type )
    {
      case 'js':
        $template = '<script type="text/javascript" src="%s"></script>';
        break;
      case 'css':
        $template = '<link rel="stylesheet" type="text/css" href="%s">';
        break;
    }

    if ( $this->use_static_assets() )
    {
      foreach ( $requested_files as $requested_file )
      {
        if ( in_array($requested_file, array_keys(static::$digests)) )
          $requested_file .= '?v=' . substr(static::$digests[$requested_file], 0, 8);

        $files[] = $requested_file;
      }
    }
    else
    {
      $request_url = join('/', array($this->rack_url(), 'files', implode('/', $requested_files)));
      if ( $json = $this->load_json($request_url) )
      {
        if ( sizeof($json) > 0 )
        {
          foreach ( $json as $file )
          {
            $files[] = $file->path . '?body=1';
          }
        }
      }
      else
      {
        static::fatal_error( "Rack server is not running." );
      }
    }

    if ( $files )
    {
      foreach ( $files as $file )
      {
        echo sprintf( $template . "\n", ($base_url . $file) );
      }
    }
  }

  // Protected

  protected static function fatal_error( $message )
  {
    ?>
    <style type="text/css" media="screen">body{margin:0;padding:0;}#fatal-error{background:#c52f24;color:white;font-family:Arial;font-size:18px;width:600px;padding:20px 0;margin:30px auto 0;text-align:center;}#fatal-error strong{display:block;font-size:22px;}</style>
    <div id="fatal-error"><strong>Phassets</strong><?=$message?></div>
    <?
    exit(0);
  }

  protected function use_static_assets()
  {
    return ( true == static::$config['static_assets'] );
  }

  protected function rack_url()
  {
    return 'http://localhost:3210';
  }

  protected function assets_url()
  {
    return sprintf(
      "%s/%s/",
      $this->use_static_assets() ? trim(static::$config['base_url'], '/') : $this->rack_url(),
      trim(static::$config['assets_path'],'/')
    );
  }

  protected function load_json_file( $path )
  {
    if ( !is_file($path) || !is_readable($path) )
      static::fatal_error( "Failed to load the file '$path'." );

    return $this->load_json($path);
  }

  protected function load_json( $path, $silent=true )
  {
    $json = (array)$this->json_clean_decode(@file_get_contents( $path ));

    if ( !$silent && NULL == $json )
      static::fatal_error( "The file '$path' has invalid JSON syntax." );

    return $json;
  }

  protected function json_clean_decode($json, $assoc = false, $depth = 512, $options = 0)
  {
    // search and remove comments like /* */ and //
    $json = preg_replace("#(/\*([^*]|[\r\n]|(\*+([^*/]|[\r\n])))*\*+/)|([\s\t]//.*)|(^//.*)#", '', $json);

    if ( version_compare(phpversion(), '5.4.0', '>=') ) {
        $json = json_decode($json, $assoc, $depth, $options);
    } elseif ( version_compare(phpversion(), '5.3.0', '>=') ) {
        $json = json_decode($json, $assoc, $depth);
    } else {
        $json = json_decode($json, $assoc);
    }

    return $json;
  }

  protected function read_local_environment()
  {
    $local_env_file = join(DIRECTORY_SEPARATOR, array(PH_BASE, 'support', 'local_environment'));

    if ( is_file($local_env_file) && is_readable($local_env_file) )
    {
      if ( $local_env = trim(@file_get_contents( $local_env_file )) ) {
        return $local_env;
      }
    }

    return null;
    
  }

}

$am = Phassets::get_instance();
$am->configure();
