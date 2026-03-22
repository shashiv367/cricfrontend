class AppConfig {
  // Supabase configuration
  // These can be set via --dart-define or use defaults for development
  static const String supabaseUrl = 
      String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://prxfvwqortyeflsuahkj.supabase.co');
  
  static const String supabaseAnonKey = 
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InByeGZ2d3FvcnR5ZWZsc3VhaGtqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY1MDIxNjAsImV4cCI6MjA4MjA3ODE2MH0.DSNQPasRPBWjgO2PsxvO7Vanyd_Grm50L_JCv3NuC_A');

  // Backend API base URL
  // Override with: flutter run --dart-define=API_BASE_URL=http://<your-ip>:3000/api
  static const String apiBaseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'http://103.233.73.55:3000/api');
}









