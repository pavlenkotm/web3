package main

import (
	"context"
	"fmt"
	"log"
	"math/big"
	"os"

	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/ethclient"
	"github.com/fatih/color"
	"github.com/spf13/cobra"
)

var rpcURL string

// Client wraps ethclient for convenience
type Client struct {
	*ethclient.Client
	ctx context.Context
}

// NewClient creates a new Ethereum client
func NewClient(url string) (*Client, error) {
	client, err := ethclient.Dial(url)
	if err != nil {
		return nil, fmt.Errorf("failed to connect: %w", err)
	}

	return &Client{
		Client: client,
		ctx:    context.Background(),
	}, nil
}

// GetBalance returns the ETH balance for an address
func (c *Client) GetBalance(address string) (*big.Int, error) {
	addr := common.HexToAddress(address)
	balance, err := c.BalanceAt(c.ctx, addr, nil)
	if err != nil {
		return nil, fmt.Errorf("failed to get balance: %w", err)
	}
	return balance, nil
}

// GetBlockNumber returns the latest block number
func (c *Client) GetBlockNumber() (uint64, error) {
	number, err := c.BlockNumber(c.ctx)
	if err != nil {
		return 0, fmt.Errorf("failed to get block number: %w", err)
	}
	return number, nil
}

// GetBlock returns block details
func (c *Client) GetBlock(number uint64) (*types.Block, error) {
	block, err := c.BlockByNumber(c.ctx, big.NewInt(int64(number)))
	if err != nil {
		return nil, fmt.Errorf("failed to get block: %w", err)
	}
	return block, nil
}

// GetChainID returns the chain ID
func (c *Client) GetChainID() (*big.Int, error) {
	chainID, err := c.ChainID(c.ctx)
	if err != nil {
		return nil, fmt.Errorf("failed to get chain ID: %w", err)
	}
	return chainID, nil
}

var rootCmd = &cobra.Command{
	Use:   "eth-rpc",
	Short: "Ethereum RPC client CLI",
	Long:  `A command-line interface for interacting with Ethereum nodes via JSON-RPC`,
}

var infoCmd = &cobra.Command{
	Use:   "info",
	Short: "Display blockchain information",
	Run: func(cmd *cobra.Command, args []string) {
		client, err := NewClient(rpcURL)
		if err != nil {
			log.Fatal(err)
		}
		defer client.Close()

		chainID, err := client.GetChainID()
		if err != nil {
			log.Fatal(err)
		}

		blockNum, err := client.GetBlockNumber()
		if err != nil {
			log.Fatal(err)
		}

		green := color.New(color.FgGreen).SprintFunc()
		cyan := color.New(color.FgCyan).SprintFunc()

		fmt.Printf("%s %s\n", cyan("Chain ID:"), green(chainID.String()))
		fmt.Printf("%s %s\n", cyan("Latest Block:"), green(blockNum))
		fmt.Printf("%s %s\n", cyan("RPC URL:"), green(rpcURL))
	},
}

var balanceCmd = &cobra.Command{
	Use:   "balance [address]",
	Short: "Get ETH balance for address",
	Args:  cobra.ExactArgs(1),
	Run: func(cmd *cobra.Command, args []string) {
		client, err := NewClient(rpcURL)
		if err != nil {
			log.Fatal(err)
		}
		defer client.Close()

		balance, err := client.GetBalance(args[0])
		if err != nil {
			log.Fatal(err)
		}

		ethBalance := new(big.Float).Quo(
			new(big.Float).SetInt(balance),
			big.NewFloat(1e18),
		)

		green := color.New(color.FgGreen).SprintFunc()
		fmt.Printf("Balance: %s ETH\n", green(ethBalance.Text('f', 6)))
	},
}

var blockCmd = &cobra.Command{
	Use:   "block [number]",
	Short: "Get block information",
	Args:  cobra.ExactArgs(1),
	Run: func(cmd *cobra.Command, args []string) {
		client, err := NewClient(rpcURL)
		if err != nil {
			log.Fatal(err)
		}
		defer client.Close()

		blockNum := new(big.Int)
		blockNum.SetString(args[0], 10)

		block, err := client.GetBlock(blockNum.Uint64())
		if err != nil {
			log.Fatal(err)
		}

		cyan := color.New(color.FgCyan).SprintFunc()
		green := color.New(color.FgGreen).SprintFunc()

		fmt.Printf("\n%s\n\n", cyan(fmt.Sprintf("Block #%d", block.NumberU64())))
		fmt.Printf("%s %s\n", cyan("Hash:"), green(block.Hash().Hex()))
		fmt.Printf("%s %s\n", cyan("Parent Hash:"), green(block.ParentHash().Hex()))
		fmt.Printf("%s %s\n", cyan("Timestamp:"), green(block.Time()))
		fmt.Printf("%s %s\n", cyan("Transactions:"), green(len(block.Transactions())))
		fmt.Printf("%s %s\n", cyan("Gas Used:"), green(block.GasUsed()))
		fmt.Printf("%s %s\n", cyan("Gas Limit:"), green(block.GasLimit()))
	},
}

func init() {
	rootCmd.PersistentFlags().StringVarP(&rpcURL, "rpc", "r", "http://localhost:8545", "Ethereum RPC URL")

	rootCmd.AddCommand(infoCmd)
	rootCmd.AddCommand(balanceCmd)
	rootCmd.AddCommand(blockCmd)
}

func main() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}
