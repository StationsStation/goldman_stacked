/* generated using openapi-typescript-codegen -- do not edit */
/* istanbul ignore file */
/* tslint:disable */
/* eslint-disable */
export type Agent = {
    id: string;
    name: string;
    /**
     * Ethereum or Web3 address
     */
    address: string;
    /**
     * Optional biography or metadata URI
     */
    profile?: string;
    /**
     * URL or IPFS link to the agent's profile image
     */
    profilePicture?: string;
    /**
     * Role of agent in the collective
     */
    role: Agent.role;
};
export namespace Agent {
    /**
     * Role of agent in the collective
     */
    export enum role {
        COUNCIL = 'council',
        VOTER = 'voter',
    }
}

