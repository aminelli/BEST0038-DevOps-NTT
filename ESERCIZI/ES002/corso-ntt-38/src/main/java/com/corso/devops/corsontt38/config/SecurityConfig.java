package com.corso.devops.corsontt38.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.provisioning.InMemoryUserDetailsManager;
import org.springframework.security.web.SecurityFilterChain;

/**
 * Configurazione di Spring Security per la gestione dell'autenticazione e autorizzazione.
 * Definisce utenti in-memory, encoder delle password e regole di accesso alle pagine.
 */
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    /**
     * Configura la catena di filtri di sicurezza.
     * 
     * @param http HttpSecurity object per configurare le regole di sicurezza
     * @return SecurityFilterChain configurata
     * @throws Exception in caso di errori di configurazione
     */
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .authorizeHttpRequests(authorize -> authorize
                // Pagine pubbliche accessibili senza autenticazione
                .requestMatchers("/", "/home", "/about", "/css/**", "/js/**", "/images/**", "/error").permitAll()
                // Area privata richiede autenticazione
                .requestMatchers("/private/**").authenticated()
                // Tutte le altre richieste sono permesse (cambiato per non bloccare le pagine pubbliche)
                .anyRequest().permitAll()
            )
            .formLogin(form -> form
                // Configurazione della pagina di login
                .loginPage("/login")
                .permitAll()
                // Redirect a dashboard dopo login riuscito
                .defaultSuccessUrl("/private/dashboard", true)
                .failureUrl("/login?error=true")
            )
            .logout(logout -> logout
                // Configurazione del logout
                .logoutUrl("/logout")
                .logoutSuccessUrl("/?logout=true")
                .permitAll()
                .invalidateHttpSession(true)
                .deleteCookies("JSESSIONID")
            );

        return http.build();
    }

    /**
     * Definisce gli utenti in-memory per l'autenticazione.
     * 
     * @return UserDetailsService con utenti hardcoded
     */
    @Bean
    public UserDetailsService userDetailsService() {
        // Crea utente normale
        UserDetails user = User.builder()
            .username("user")
            .password(passwordEncoder().encode("user123"))
            .roles("USER")
            .build();

        // Crea amministratore
        UserDetails admin = User.builder()
            .username("admin")
            .password(passwordEncoder().encode("admin123"))
            .roles("USER", "ADMIN")
            .build();

        // Crea altro utente di test
        UserDetails mario = User.builder()
            .username("mario")
            .password(passwordEncoder().encode("mario123"))
            .roles("USER")
            .build();

        return new InMemoryUserDetailsManager(user, admin, mario);
    }

    /**
     * Bean per l'encoding delle password con BCrypt.
     * 
     * @return PasswordEncoder BCrypt
     */
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
