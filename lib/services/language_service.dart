import 'package:flutter/material.dart';

class LanguageService {
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();

  String _currentLanguage = 'en';

  String get currentLanguage => _currentLanguage;
  Locale get currentLocale {
    switch (_currentLanguage) {
      case 'fr': return const Locale('fr');
      case 'pt': return const Locale('pt');
      default: return const Locale('en');
    }
  }

  void setLanguage(String lang) {
    _currentLanguage = lang;
  }

  Map<String, Map<String, String>> _translations = {
    'en': {
      'welcome': 'Welcome Back 👋',
      'sign_in': 'Sign In',
      'sign_up': 'Sign Up',
      'guest': 'Continue as Guest',
      'email': 'Email address',
      'password': 'Password',
      'full_name': 'Full Name',
      'phone': 'Phone Number',
      'create_account': 'Create Account',
      'my_bookings': 'My Bookings',
      'profile': 'My Profile',
      'notifications': 'Notifications',
      'help': 'Help & Support',
      'sign_out': 'Sign Out',
      'find_stay': 'Find a Place to Stay',
      'business': 'Business Travel Solutions',
      'special': 'Special Requests',
      'shuttle': 'Shuttle Service',
      'tours': 'City Tours',
      'companion': 'Companion Service',
      'dining': 'Dining Reservations',
      'flights': 'Flight Booking',
      'guardian': 'Trip Guardian™',
      'emergency': 'Need Emergency Help?',
      'explore': 'Explore All',
      'hotels': 'Hotels',
      'apartments': 'Apartments',
      'services': 'Our Services',
      'see_all': 'See All',
      'guest_banner': 'Browsing as guest. Create an account for exclusive perks!',
      'guest_profile': 'Guest User',
      'guest_subtitle': 'Sign up to unlock all features',
    },
    'fr': {
      'welcome': 'Bon retour 👋',
      'sign_in': 'Se connecter',
      'sign_up': 'S\'inscrire',
      'guest': 'Continuer en tant qu\'invité',
      'email': 'Adresse e-mail',
      'password': 'Mot de passe',
      'full_name': 'Nom complet',
      'phone': 'Numéro de téléphone',
      'create_account': 'Créer un compte',
      'my_bookings': 'Mes réservations',
      'profile': 'Mon profil',
      'notifications': 'Notifications',
      'help': 'Aide et support',
      'sign_out': 'Se déconnecter',
      'find_stay': 'Trouver un logement',
      'business': 'Solutions voyage d\'affaires',
      'special': 'Demandes spéciales',
      'shuttle': 'Service de navette',
      'tours': 'Visites guidées',
      'companion': 'Service d\'accompagnement',
      'dining': 'Réservations restaurant',
      'flights': 'Réservation de vol',
      'guardian': 'Trip Guardian™',
      'emergency': 'Besoin d\'aide d\'urgence?',
      'explore': 'Explorer tout',
      'hotels': 'Hôtels',
      'apartments': 'Appartements',
      'services': 'Nos services',
      'see_all': 'Voir tout',
      'guest_banner': 'Navigation en tant qu\'invité. Créez un compte pour des avantages exclusifs!',
      'guest_profile': 'Utilisateur invité',
      'guest_subtitle': 'Inscrivez-vous pour débloquer toutes les fonctionnalités',
    },
    'pt': {
      'welcome': 'Bem-vindo de volta 👋',
      'sign_in': 'Entrar',
      'sign_up': 'Cadastrar',
      'guest': 'Continuar como convidado',
      'email': 'Endereço de e-mail',
      'password': 'Senha',
      'full_name': 'Nome completo',
      'phone': 'Número de telefone',
      'create_account': 'Criar conta',
      'my_bookings': 'Minhas reservas',
      'profile': 'Meu perfil',
      'notifications': 'Notificações',
      'help': 'Ajuda e suporte',
      'sign_out': 'Sair',
      'find_stay': 'Encontrar um lugar',
      'business': 'Soluções para negócios',
      'special': 'Pedidos especiais',
      'shuttle': 'Serviço de transporte',
      'tours': 'Passeios pela cidade',
      'companion': 'Serviço de acompanhante',
      'dining': 'Reservas de restaurante',
      'flights': 'Reserva de voo',
      'guardian': 'Trip Guardian™',
      'emergency': 'Precisa de ajuda urgente?',
      'explore': 'Explorar tudo',
      'hotels': 'Hotéis',
      'apartments': 'Apartamentos',
      'services': 'Nossos serviços',
      'see_all': 'Ver tudo',
      'guest_banner': 'Navegando como convidado. Crie uma conta para vantagens exclusivas!',
      'guest_profile': 'Usuário convidado',
      'guest_subtitle': 'Cadastre-se para desbloquear todos os recursos',
    },
  };

  String t(String key) {
    return _translations[_currentLanguage]?[key] ?? _translations['en']?[key] ?? key;
  }
}