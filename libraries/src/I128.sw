library I128;
use core::num::*;
use std::assert::assert;
use std::u128::*;

/// The 24-bit signed integer type.
/// Represented as an underlying U128 value.
/// Actual value is underlying value minus 2 ^ 128
/// Max value is 2 ^ 128 - 1, min value is - 2 ^ 128
pub struct I128 {
    underlying: U128,
}

pub trait From {
    /// Function for creating I128 from U128
    fn from(underlying: U128) -> Self;
}
    
impl I128 {
    /// Helper function to get a signed number from with an underlying
    fn from_u128(underlying: U128) -> Self {
        assert(underlying.upper & 0x8000000000000000 == 0);
        Self { underlying }
    }
}

// Main math and comparison Ops

impl core::ops::Eq for I128 {
    fn eq(self, other: Self) -> bool {
        self.underlying == other.underlying
    }
}

impl core::ops::Ord for I128 {
    fn gt(self, other: Self) -> bool {
        self.underlying > other.underlying
    }
    fn lt(self, other: Self) -> bool {
        self.underlying < other.underlying
    }
}

impl I128 {
    /// The underlying value that corresponds to zero signed value
    pub fn indent() -> U128 {
        // With 24 bits max value that can be expressed is 16,777,215
        // I128 required values are from (-2 ^ 127) to (2 ^ 127) - 1
        // So zero value must be 8,388,608 to cover the full range
        ~U128::from(0x8000000000000000, 0x0000000000000000)
    }
}

impl I128 {
    // Return the underlying value
    pub fn into(self) -> U128 {
        self.underlying
    }
}

impl I128 {
    /// Initializes a new, zeroed I128.
    pub fn new() -> Self {
        Self {
            underlying: ~Self::indent(),
        }
    }
    pub fn abs(self) -> U128 {
        let is_gt_zero: bool = (self.underlying > ~Self::indent()) || (self.underlying == ~Self::indent());
        let abs_pos = self.underlying - ~Self::indent();
        let abs_neg = ~Self::indent() + (~Self::indent() - self.underlying);
        let abs_value = if is_gt_zero {
            abs_pos
        } else {
            abs_neg
        };
        abs_value
    }
    /// The smallest value that can be represented by this integer type.
    pub fn min() -> Self {
        // Return 0U128 which is actually −8,388,608
        Self {
            underlying: ~U128::from(0,0),
        }
    }
    /// The largest value that can be represented by this type,
    pub fn max() -> Self {
        // Return max 24-bit number which is actually 8,388,607
        Self {
            underlying: ~U128::max(),
        }
    }
    /// The size of this type in bits.
    pub fn bits() -> U128 {
        ~U128::from(0,128)
    }
    /// Helper function to get a negative value of unsigned numbers
    pub fn from_neg(value: U128) -> Self {
        assert(value.upper & 0x8000000000000000 == 0);
        Self {
            underlying: ~Self::indent() - value,
        }
    }
    /// Helper function to get a positive value from unsigned number
    pub fn from_uint(value: U128) -> Self {
        // as the minimal value of I128 is 2147483648 (1 << 31) we should add ~I128::indent() (1 << 31) 
        let underlying: U128 = value + ~Self::indent();
        assert(underlying.upper & 0x8000000000000000 == 0);
        Self { underlying }
    }
}

impl core::ops::Add for I128 {
    /// Add a I128 to a I128. Panics on overflow.
    fn add(self, other: Self) -> Self {
        // subtract 1 << 24 to avoid a double move, then from will perform the overflow check
        ~Self::from_u128(self.underlying - ~Self::indent() + other.underlying)
    }
}

impl core::ops::Subtract for I128 {
    /// Subtract a I128 from a I128. Panics of overflow.
    fn subtract(self, other: Self) -> Self {
        let mut res = ~Self::new();
        if self > other {
            // add 1 << 31 to avoid loosing the move
            res = ~Self::from_u128(self.underlying - other.underlying + ~Self::indent());
        } else {
            // subtract from 1 << 31 as we are getting a negative value
            res = ~Self::from_u128(~Self::indent() - (other.underlying - self.underlying));
        }
        res
    }
}

impl core::ops::Multiply for I128 {
    /// Multiply a I128 with a I128. Panics of overflow.
    fn multiply(self, other: Self) -> Self {
        let mut res = ~Self::new();
        if (self.underlying > ~Self::indent() || self.underlying == ~Self::indent())
            && (other.underlying > ~Self::indent() || other.underlying == ~Self::indent())
        {
            res = ~Self::from_u128((self.underlying - ~Self::indent()) * (other.underlying - ~Self::indent()) + ~Self::indent());
        } else if self.underlying < ~Self::indent()
            && other.underlying < ~Self::indent()
        {
            res = ~Self::from_u128((~Self::indent() - self.underlying) * (~Self::indent() - other.underlying) + ~Self::indent());
        } else if self.underlying > ~Self::indent() || self.underlying == ~Self::indent()
            && other.underlying < ~Self::indent()
        {
            res = ~Self::from_u128(~Self::indent() - (self.underlying - ~Self::indent()) * (~Self::indent() - other.underlying));
        } else if self.underlying < ~Self::indent()
            && (other.underlying > ~Self::indent() || other.underlying == ~Self::indent())
        {
            res = ~Self::from_u128(~Self::indent() - (other.underlying - ~Self::indent()) * (~Self::indent() - self.underlying));
        }

        // Overflow protection
        assert((res < ~Self::max()) || (res == ~Self::max()));

        res
    }
}

impl core::ops::Divide for I128 {
    /// Divide a I128 by a I128. Panics if divisor is zero.
    fn divide(self, divisor: Self) -> Self {
        assert(divisor != ~Self::new());
        let mut res = ~Self::new();
        if (self.underlying > ~Self::indent() || self.underlying == ~Self::indent())
            && divisor.underlying > ~Self::indent()
        {
            res = ~Self::from_u128((self.underlying - ~Self::indent()) / (divisor.underlying - ~Self::indent()) + ~Self::indent());
        } else if self.underlying < ~Self::indent()
            && divisor.underlying < ~Self::indent()
        {
            res = ~Self::from_u128((~Self::indent() - self.underlying) / (~Self::indent() - divisor.underlying) + ~Self::indent());
        } else if (self.underlying > ~Self::indent() || self.underlying == ~Self::indent())
            && divisor.underlying < ~Self::indent()
        {
            res = ~Self::from_u128(~Self::indent() - (self.underlying - ~Self::indent()) / (~Self::indent() - divisor.underlying));
        } else if self.underlying < ~Self::indent()
            && divisor.underlying > ~Self::indent()
        {
            res = ~Self::from_u128(~Self::indent() - (~Self::indent() - self.underlying) / (divisor.underlying - ~Self::indent()));
        }
        res
    }
}

impl core::ops::Mod for I128{
    fn modulo(self, other: I128) -> I128 {
        return (self - other * (self / other));
    }
}
