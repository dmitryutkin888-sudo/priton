package main

import (
    "fmt"
    "os"
)

func main() {
    if len(os.Args) < 2 {
        fmt.Println("usage: priton-cli <status|add-node|reset-admin|logs>")
        os.Exit(1)
    }

    switch os.Args[1] {
    case "status":
        fmt.Println("Priton services: api=ok postgres=ok redis=ok bot=ok")
    case "add-node":
        fmt.Println("node registration placeholder")
    case "reset-admin":
        fmt.Println("admin reset placeholder")
    case "logs":
        fmt.Println("tail logs placeholder")
    default:
        fmt.Printf("unknown command: %s\n", os.Args[1])
        os.Exit(1)
    }
}
