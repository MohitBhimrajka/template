import * as React from "react"
import { cn } from "@/lib/utils"
import { Button, ButtonProps } from "./button"

// Special branded buttons using exact brand colors

export const AccentButton = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, ...props }, ref) => {
    return (
      <Button
        className={cn(
          "bg-brand-lime text-brand-black hover:bg-brand-light-lime",
          className
        )}
        ref={ref}
        {...props}
      />
    )
  }
)
AccentButton.displayName = "AccentButton"

export const NavyButton = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, ...props }, ref) => {
    return (
      <Button
        className={cn(
          "bg-brand-navy text-brand-white hover:bg-brand-soft-blue",
          className
        )}
        ref={ref}
        {...props}
      />
    )
  }
)
NavyButton.displayName = "NavyButton"

export const CoralButton = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, ...props }, ref) => {
    return (
      <Button
        className={cn(
          "bg-brand-coral-orange text-brand-white hover:bg-brand-light-pink",
          className
        )}
        ref={ref}
        {...props}
      />
    )
  }
)
CoralButton.displayName = "CoralButton"
