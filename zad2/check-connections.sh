#!/bin/bash

# Zmienna przechowująca status wyjścia
exit_status=0

# Funkcja do sprawdzania połączenia między kontenerami
check_connection() {
  local source=$1
  local target=$2
  local target_ip

  # Pobieranie adresu IP kontenera docelowego
  target_ip=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$target")
  if [[ -z "$target_ip" ]]; then
    echo "Nie udało się znaleźć adresu IP dla $target"
    exit_status=1
    return
  fi

  # Wykonanie polecenia ping z kontenera źródłowego do kontenera docelowego
  if docker exec "$source" ping -c 1 "$target_ip" > /dev/null; then
    echo "Połączenie z $source do $target ($target_ip) jest poprawne."
  else
    echo "Połączenie z $source do $target ($target_ip) NIE jest poprawne."
    exit_status=1
  fi
}

# Pobieranie ID kontenerów po ich nazwach
frontend_id=$(docker ps -qf "name=frontend")
backend_id=$(docker ps -qf "name=backend")
database_id=$(docker ps -qf "name=database")

# Sprawdzenie połączenia z frontend do backend
check_connection "$frontend_id" "$backend_id"

# Sprawdzenie połączenia z backend do database
check_connection "$backend_id" "$database_id"

# Zwrócenie końcowego statusu
exit $exit_status
