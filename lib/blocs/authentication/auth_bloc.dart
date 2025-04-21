import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SupabaseClient _supabase = Supabase.instance.client;

  AuthBloc() : super(AuthInitial()) {
    // Register new user.
    on<SignUpRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final response = await _supabase.auth.signUp(
          email: event.email,
          password: event.password,
        );
        if (response.user != null) {
          emit(AuthSuccess());
        } else {
          print('eoorrr');
          emit(AuthError(message: 'Sign up failed!'));
        }
      } catch (e) {
        print(e.toString());
        emit(AuthError(message: e.toString()));
      }
    });

    // Login user.
    on<SignInRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final response = await _supabase.auth.signInWithPassword(
          email: event.email,
          password: event.password,
        );
        if (response.user != null) {
          emit(AuthSuccess());
        } else {
          emit(AuthError(message: 'Sign in failed'));
        }
      } catch (e) {
        print(e.toString());
        emit(AuthError(message: e.toString()));
      }
    });

    // Logout user.
    on<SignOutRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await _supabase.auth.signOut();
        emit(AuthUnauthenticated());
      } catch (e) {
        emit(AuthError(message: e.toString()));
      }
    });

    on<AuthStateChanged>((event, emit) {
      if (event.user != null) {
        emit(AuthSuccess());
      } else {
        emit(AuthUnauthenticated());
      }
    });

    on<CheckIfUserIsLoggedIn>((event, emit) async {
      _supabase.auth.onAuthStateChange.listen((data) {
        if (data.session == null) {
          emit(AuthUnauthenticated());
        }
      });
    });
  }
}
